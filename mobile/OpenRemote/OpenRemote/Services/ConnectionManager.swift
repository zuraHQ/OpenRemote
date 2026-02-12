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
    @Published var previewUrl: String?
    @Published var isPreviewLoading: Bool = false
    @Published var currentActivity: String = ""
    
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
        currentActivity = ""
        
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
        currentActivity = "Starting..."
        
        let model = UserDefaults.standard.string(forKey: "claudeModel") ?? "sonnet"
        let escapedText = text.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "`", with: "\\`")
        
        var command: String
        if let sid = claudeSessionId {
            command = "claude -p \"\(escapedText)\" --resume \(sid) --model \(model) --output-format stream-json --verbose --dangerously-skip-permissions"
        } else {
            command = "claude -p \"\(escapedText)\" --model \(model) --output-format stream-json --verbose --dangerously-skip-permissions"
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
        currentActivity = ""
        isClaudeThinking = false
    }
    
    func startPreview(port: Int = 3000) {
        isPreviewLoading = true
        send(.startPreview(port: port))
    }
    
    func stopPreview() {
        send(.stopPreview)
        previewUrl = nil
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

        case .previewReady(let url, _):
            isPreviewLoading = false
            previewUrl = url
            
        case .previewError:
            isPreviewLoading = false
            previewUrl = nil
            
        case .previewStopped:
            previewUrl = nil

        case .pong, .unknown:
            break
        }
    }
    
    private func processClaudeOutput(_ rawText: String) {
        let cleanedRaw = stripAnsiCodes(rawText)
        jsonLineBuffer += cleanedRaw

        print("[OpenRemote] Raw chunk (\(cleanedRaw.count) chars): \(cleanedRaw.prefix(200))")

        guard isWaitingForResponse else {
            print("[OpenRemote] Not waiting for response, skipping")
            return
        }

        let lines = jsonLineBuffer.components(separatedBy: "\n")
        jsonLineBuffer = lines.last ?? ""

        // Process complete lines + try last line if it looks like complete JSON
        var linesToProcess = Array(lines.dropLast())
        if let lastLine = lines.last {
            let trimmedLast = lastLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLast.hasPrefix("{") && trimmedLast.hasSuffix("}") {
                linesToProcess.append(lastLine)
                jsonLineBuffer = ""
            }
        }

        print("[OpenRemote] Processing \(linesToProcess.count) lines, buffer remaining: \(jsonLineBuffer.count) chars")

        var parsedAny = false

        for line in linesToProcess {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, trimmed.hasPrefix("{") else { continue }

            guard let data = trimmed.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else {
                print("[OpenRemote] Failed to parse JSON: \(trimmed.prefix(100))")
                continue
            }

            parsedAny = true
            print("[OpenRemote] JSON event: \(type) | keys: \(json.keys.sorted().joined(separator: ", "))")

            switch type {
            case "system":
                if let sid = json["session_id"] as? String {
                    claudeSessionId = sid
                    print("[OpenRemote] Session ID: \(sid)")
                }
                currentActivity = "Thinking..."
                updateToolActivity(currentActivity)

            case "assistant":
                if let message = json["message"] as? [String: Any],
                   let content = message["content"] as? [[String: Any]] {
                    for item in content {
                        if let itemType = item["type"] as? String {
                            if itemType == "tool_use" {
                                let toolName = item["name"] as? String ?? "tool"
                                let input = item["input"] as? [String: Any]
                                currentActivity = formatToolActivity(toolName, input: input)
                                updateToolActivity(currentActivity)
                                print("[OpenRemote] Tool use: \(toolName) → \(currentActivity)")
                            } else if itemType == "text" {
                                if let text = item["text"] as? String, !text.isEmpty {
                                    appendToResponse(text)
                                    currentActivity = "Writing response..."
                                    updateToolActivity(currentActivity)
                                    print("[OpenRemote] Text content: \(text.prefix(80))...")
                                }
                            }
                        }
                    }
                } else {
                    print("[OpenRemote] Assistant message but couldn't parse content. Keys: \(json.keys.sorted())")
                    currentActivity = "Thinking..."
                    updateToolActivity(currentActivity)
                }

            case "user":
                currentActivity = "Processing result..."
                updateToolActivity(currentActivity)
                if let toolResult = json["tool_use_result"] as? [String: Any] {
                    if toolResult["isImage"] as? Bool == true {
                        currentActivity = "Processing image..."
                        updateToolActivity(currentActivity)
                    }
                }

            case "result":
                if let sid = json["session_id"] as? String {
                    claudeSessionId = sid
                }

                var finalText: String?
                if let result = json["result"] as? String {
                    finalText = result
                    print("[OpenRemote] Result text: \(result.prefix(100))...")
                } else if let subtype = json["subtype"] as? String, subtype == "error_response" {
                    finalText = json["error"] as? String ?? "An error occurred."
                    print("[OpenRemote] Error result: \(finalText ?? "")")
                } else {
                    print("[OpenRemote] Result with no text. Keys: \(json.keys.sorted())")
                }

                if let currentMsg = currentAssistantMessage,
                   let index = messages.firstIndex(where: { $0.id == currentMsg.id }) {
                    var updated = messages[index]
                    if let text = finalText, !text.isEmpty {
                        updated.content = text
                    }
                    updated.isStreaming = false
                    updated.toolActivity = nil
                    messages[index] = updated
                    print("[OpenRemote] Finalized message, content length: \(updated.content.count)")
                } else {
                    print("[OpenRemote] WARNING: Could not find assistant message to finalize")
                }

                isClaudeThinking = false
                isWaitingForResponse = false
                currentAssistantMessage = nil
                currentActivity = ""
                jsonLineBuffer = ""

            default:
                print("[OpenRemote] Unknown event type: \(type)")
                break
            }
        }

        // If we received data but couldn't parse any JSON, update activity so UI isn't stuck
        if !parsedAny && !cleanedRaw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if currentActivity == "Starting..." || currentActivity.isEmpty {
                currentActivity = "Processing..."
                updateToolActivity(currentActivity)
            }
        }

        let hasShellPrompt = cleanedRaw.contains("% ") || cleanedRaw.contains("$ ") || cleanedRaw.contains("❯")
        if hasShellPrompt && !jsonLineBuffer.contains("{") && jsonLineBuffer.count < 50 {
            print("[OpenRemote] Shell prompt detected, finalizing")
            isClaudeThinking = false
            isWaitingForResponse = false

            if let currentMsg = currentAssistantMessage,
               let index = messages.firstIndex(where: { $0.id == currentMsg.id }) {
                if messages[index].content.isEmpty {
                    print("[OpenRemote] Removing empty assistant message")
                    messages.remove(at: index)
                } else {
                    var updated = messages[index]
                    updated.isStreaming = false
                    updated.toolActivity = nil
                    messages[index] = updated
                    print("[OpenRemote] Finalized message on shell prompt, content length: \(updated.content.count)")
                }
            }
            currentAssistantMessage = nil
            currentActivity = ""
            jsonLineBuffer = ""
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

        // Convert line endings FIRST, before anything else strips \r
        result = result.replacingOccurrences(of: "\r\n", with: "\n")
        result = result.replacingOccurrences(of: "\r", with: "\n")

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

        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return result
    }
}
