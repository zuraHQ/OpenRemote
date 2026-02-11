import Foundation
import Combine

@MainActor
class ConnectionManager: ObservableObject {
    @Published var state: ConnectionState = .disconnected
    @Published var terminalOutput: String = ""
    @Published var sessionId: String?
    @Published var activeSessions: [String] = []
    @Published var messages: [ChatMessage] = []
    @Published var isClaudeThinking: Bool = false
    @Published var showTrustPrompt: Bool = false
    
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession?
    private var token: String?
    private var pingTimer: Timer?
    private var outputBuffer: String = ""
    private var jsonLineBuffer: String = ""
    private var currentAssistantMessage: ChatMessage?
    private var isWaitingForResponse: Bool = false
    private var claudeSessionId: String?

    func connect(info: ConnectionInfo) {
        disconnect()
        token = info.token
        info.save()

        var wsUrl = info.url
        if wsUrl.hasPrefix("https://") {
            wsUrl = wsUrl.replacingOccurrences(of: "https://", with: "wss://")
        } else if wsUrl.hasPrefix("http://") {
            wsUrl = wsUrl.replacingOccurrences(of: "http://", with: "ws://")
        } else if !wsUrl.hasPrefix("ws://") && !wsUrl.hasPrefix("wss://") {
            wsUrl = "wss://\(wsUrl)"
        }

        guard let url = URL(string: wsUrl) else {
            state = .failed("Invalid URL")
            return
        }

        state = .connecting
        session = URLSession(configuration: .default)
        webSocket = session?.webSocketTask(with: url)
        webSocket?.resume()

        state = .authenticating
        send(.auth(token: info.token))
        listenForMessages()
        startPinging()
    }

    func disconnect(clearSaved: Bool = true) {
        pingTimer?.invalidate()
        pingTimer = nil
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        session?.invalidateAndCancel()
        session = nil
        sessionId = nil
        state = .disconnected
        isClaudeThinking = false
        showTrustPrompt = false
        isWaitingForResponse = false
        claudeSessionId = nil
        outputBuffer = ""
        jsonLineBuffer = ""
        
        if clearSaved {
            ConnectionInfo.clear()
        }
    }

    func createSession() {
        send(.createSession(cols: 120, rows: 40))
    }

    func sendInput(_ text: String) {
        guard let sid = sessionId else { return }
        send(.input(sessionId: sid, data: text))
    }

    func sendCommand(_ command: String) {
        sendInput(command + "\r")
    }

    func killSession() {
        guard let sid = sessionId else { return }
        send(.kill(sessionId: sid))
        sessionId = nil
    }
    
    func sendChatMessage(_ text: String) {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        
        currentAssistantMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
        messages.append(currentAssistantMessage!)
        
        isClaudeThinking = true
        isWaitingForResponse = true
        outputBuffer = ""
        
        let model = UserDefaults.standard.string(forKey: "claudeModel") ?? "sonnet"
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "`", with: "\\`")
        
        var command: String
        if let sid = claudeSessionId {
            command = "claude -p \"\(escapedText)\" --resume \(sid) --model \(model) --output-format json --dangerously-skip-permissions"
        } else {
            command = "claude -p \"\(escapedText)\" --model \(model) --output-format json --dangerously-skip-permissions"
        }
        
        print("[OpenRemote] Command: \(command)")
        sendCommand(command)
    }
    
    func acceptTrust() {
        sendInput("y\r")
        showTrustPrompt = false
    }
    
    func clearMessages() {
        messages.removeAll()
        outputBuffer = ""
        jsonLineBuffer = ""
        currentAssistantMessage = nil
        isWaitingForResponse = false
        claudeSessionId = nil
    }

    private func send(_ message: OutgoingMessage) {
        let json = message.toJSON()
        webSocket?.send(.string(json)) { error in
            if let error {
                Task { @MainActor in
                    self.state = .failed(error.localizedDescription)
                }
            }
        }
    }

    private func listenForMessages() {
        webSocket?.receive { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(.string(let text)):
                    self.handleMessage(IncomingMessage.parse(text))
                    self.listenForMessages()
                case .success:
                    self.listenForMessages()
                case .failure(let error):
                    if self.state != .disconnected {
                        self.state = .failed(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func handleMessage(_ msg: IncomingMessage) {
        switch msg {
        case .authOk:
            state = .connected
            createSession()

        case .sessionCreated(let sid):
            sessionId = sid
            terminalOutput = ""
            outputBuffer = ""

        case .output(_, let data):
            processClaudeOutput(data)
            let cleaned = stripAnsiCodes(data)
            terminalOutput += cleaned

        case .sessionEnded(let sid, _):
            if sessionId == sid {
                sessionId = nil
            }

        case .sessions(let list):
            activeSessions = list

        case .error(let message):
            if state != .connected {
                state = .failed(message)
            }

        case .pong, .unknown:
            break
        }
    }
    
    private func processClaudeOutput(_ rawText: String) {
        let cleanedRaw = stripAnsiCodes(rawText)
        outputBuffer += cleanedRaw
        
        guard isWaitingForResponse else { return }
        
        print("[OpenRemote] Buffer: \(outputBuffer.suffix(200))")
        
        if let jsonStart = outputBuffer.firstIndex(of: "{"),
           let jsonEnd = outputBuffer.lastIndex(of: "}") {
            let jsonString = String(outputBuffer[jsonStart...jsonEnd])
            
            if let data = jsonString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                if let result = json["result"] as? String {
                    print("[OpenRemote] Got result: \(result.prefix(100))")
                    
                    if let sid = json["session_id"] as? String {
                        claudeSessionId = sid
                    }
                    
                    if let currentMsg = currentAssistantMessage,
                       let index = messages.firstIndex(where: { $0.id == currentMsg.id }) {
                        var updated = messages[index]
                        updated.content = result
                        updated.isStreaming = false
                        updated.toolActivity = nil
                        messages[index] = updated
                    }
                    
                    isClaudeThinking = false
                    isWaitingForResponse = false
                    currentAssistantMessage = nil
                    outputBuffer = ""
                    return
                }
            }
        }
        
        let hasShellPrompt = cleanedRaw.contains("% ") || cleanedRaw.contains("$ ") || cleanedRaw.contains("❯")
        if hasShellPrompt && !outputBuffer.contains("{") {
            isClaudeThinking = false
            isWaitingForResponse = false
            
            if let currentMsg = currentAssistantMessage,
               let index = messages.firstIndex(where: { $0.id == currentMsg.id }) {
                if messages[index].content.isEmpty {
                    messages.remove(at: index)
                }
            }
            currentAssistantMessage = nil
            outputBuffer = ""
        }
    }
    
    private func formatToolActivity(_ toolName: String, input: [String: Any]?) -> String {
        switch toolName {
        case "Bash":
            let cmd = input?["command"] as? String ?? ""
            let desc = input?["description"] as? String ?? ""
            return desc.isEmpty ? "Running: \(cmd.prefix(50))" : desc
        case "Read":
            let path = input?["file_path"] as? String ?? input?["filePath"] as? String ?? ""
            return "Reading: \(path.components(separatedBy: "/").last ?? path)"
        case "Write":
            let path = input?["file_path"] as? String ?? input?["filePath"] as? String ?? ""
            return "Writing: \(path.components(separatedBy: "/").last ?? path)"
        case "Edit":
            let path = input?["file_path"] as? String ?? input?["filePath"] as? String ?? ""
            return "Editing: \(path.components(separatedBy: "/").last ?? path)"
        case "Glob":
            let pattern = input?["pattern"] as? String ?? ""
            return "Searching: \(pattern)"
        case "Grep":
            let pattern = input?["pattern"] as? String ?? ""
            return "Searching for: \(pattern)"
        case "WebFetch":
            return "Fetching web content..."
        case "WebSearch":
            return "Searching the web..."
        case "Task":
            return "Running sub-task..."
        default:
            return "Using \(toolName)..."
        }
    }
    
    private func updateToolActivity(_ activity: String) {
        guard let currentMsg = currentAssistantMessage,
              let index = messages.firstIndex(where: { $0.id == currentMsg.id }) else { return }
        var updated = messages[index]
        updated.toolActivity = activity
        messages[index] = updated
    }
    
    private func appendToResponse(_ text: String) {
        guard let currentMsg = currentAssistantMessage,
              let index = messages.firstIndex(where: { $0.id == currentMsg.id }) else { return }
        var updated = messages[index]
        if updated.content.isEmpty {
            updated.content = text
        } else {
            updated.content += text
        }
        messages[index] = updated
    }
    
    private func startPinging() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.send(.ping)
        }
    }

    private func stripAnsiCodes(_ string: String) -> String {
        var result = string
        
        let patterns = [
            "\u{1b}\\[[0-9;]*[a-zA-Z]",
            "\u{1b}\\[[0-9;]*[mGKHJsu]",
            "\u{1b}\\][^\u{07}]*\u{07}",
            "\u{1b}[()][AB012]",
            "\u{1b}\\[\\?[0-9;]*[hl]",
            "\u{1b}\\[>[0-9;]*[a-zA-Z]",
            "\u{1b}\\[[<>=?]?[0-9;]*[a-zA-Z]",
            "\u{1b}=",
            "\u{1b}>",
            "\u{07}",
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: ""
                )
            }
        }
        
        result = result.filter { char in
            let scalar = char.unicodeScalars.first!
            return scalar.value >= 32 || scalar == "\n" || scalar == "\t"
        }
        
        result = result.replacingOccurrences(of: "\r\n", with: "\n")
        result = result.replacingOccurrences(of: "\r", with: "\n")
        
        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        
        return result
    }
}
