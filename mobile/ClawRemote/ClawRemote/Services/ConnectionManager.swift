import Foundation
import Combine

@MainActor
class ConnectionManager: ObservableObject {
    @Published var state: ConnectionState = .disconnected
    @Published var terminalOutput: String = ""
    @Published var sessionId: String?
    @Published var activeSessions: [String] = []
    
    // Chat
    @Published var messages: [ChatMessage] = []
    @Published var isClaudeThinking: Bool = false
    @Published var showTrustPrompt: Bool = false
    
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession?
    private var token: String?
    private var pingTimer: Timer?
    
    // Buffer for parsing Claude output
    private var outputBuffer: String = ""
    private var isClaudeRunning: Bool = false
    private var isClaudeReady: Bool = false
    private var pendingUserMessage: String?
    private var currentAssistantMessage: ChatMessage?

    func connect(info: ConnectionInfo) {
        disconnect()
        token = info.token
        
        // Save connection for auto-reconnect
        info.save()

        // Convert tunnel URL to WebSocket URL
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
        isClaudeRunning = false
        isClaudeReady = false
        isClaudeThinking = false
        showTrustPrompt = false
        pendingUserMessage = nil
        
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
    
    // MARK: - Chat Methods
    
    func sendChatMessage(_ text: String) {
        // Add user message to chat
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        
        // If Claude CLI not running, start it first
        if !isClaudeRunning {
            pendingUserMessage = text
            startClaude()
            isClaudeThinking = true
        } else if isClaudeReady {
            // Claude is ready, send message directly
            sendInput(text + "\r")
            isClaudeThinking = true
            
            // Create streaming assistant message placeholder
            currentAssistantMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
            messages.append(currentAssistantMessage!)
        } else {
            // Claude running but not ready yet, queue the message
            pendingUserMessage = text
            isClaudeThinking = true
        }
    }
    
    func acceptTrust() {
        // Send Enter to accept "Yes, I trust this folder"
        sendInput("\r")
        showTrustPrompt = false
    }
    
    func clearMessages() {
        messages.removeAll()
        outputBuffer = ""
        currentAssistantMessage = nil
        pendingUserMessage = nil
        // Kill current session and start fresh
        if sessionId != nil {
            killSession()
            createSession()
        }
        isClaudeRunning = false
        isClaudeReady = false
    }
    
    private func startClaude() {
        // Start Claude CLI in the terminal
        sendCommand("claude")
        isClaudeRunning = true
    }
    
    // MARK: - Private Methods

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
            // Process raw data first for detection, then clean for display
            processClaudeOutput(data)
            let cleaned = stripAnsiCodes(data)
            terminalOutput += cleaned

        case .sessionEnded(let sid, _):
            if sessionId == sid {
                sessionId = nil
                isClaudeRunning = false
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
        outputBuffer += rawText
        
        // Detect trust prompt - Claude asks to trust the folder on first run
        // Look for key phrases in raw output
        let hasTrustPrompt = outputBuffer.contains("Yes, I trust") || 
                            outputBuffer.contains("trust this folder") ||
                            outputBuffer.contains("Enter to confirm")
        
        if hasTrustPrompt && !isClaudeReady && !showTrustPrompt {
            showTrustPrompt = true
            isClaudeThinking = false
            return
        }
        
        // Detect when Claude is ready for input (shows the prompt)
        // Claude shows "❯" when ready for input after startup
        let isReady = outputBuffer.contains("❯") && !hasTrustPrompt
        
        if isReady && !isClaudeReady {
            isClaudeReady = true
            showTrustPrompt = false
            outputBuffer = ""
            
            // Send pending message if any
            if let pending = pendingUserMessage {
                pendingUserMessage = nil
                sendInput(pending + "\r")
                
                // Create streaming assistant message placeholder
                currentAssistantMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
                messages.append(currentAssistantMessage!)
            } else {
                isClaudeThinking = false
            }
            return
        }
        
        // Skip if Claude not ready yet
        guard isClaudeReady else { return }
        
        // Check if Claude is done responding (prompt appears again)
        let hasPrompt = outputBuffer.contains("❯")
        
        // Clean the buffer for display
        let cleanedBuffer = stripAnsiCodes(outputBuffer)
        
        // Skip setup/noise patterns
        let skipPatterns = [
            "Accessing", "workspace", "Quick safety", 
            "Security guide", "Enter to confirm", "Esc to cancel",
            "Yes, I trust", "No, exit"
        ]
        
        // Extract meaningful content for chat
        if let currentMsg = currentAssistantMessage,
           let index = messages.firstIndex(where: { $0.id == currentMsg.id }) {
            
            var content = cleanedBuffer
            
            // Remove prompt characters
            content = content.replacingOccurrences(of: "❯", with: "")
            
            // Check if this is just setup/noise
            let isNoise = skipPatterns.contains { content.contains($0) }
            
            let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !isNoise && !trimmedContent.isEmpty {
                // Update the message content
                var updated = messages[index]
                updated.content = trimmedContent
                updated.isStreaming = !hasPrompt
                messages[index] = updated
            }
            
            if hasPrompt {
                // Claude finished responding
                isClaudeThinking = false
                
                // If message is empty/noise, remove it
                if messages[index].content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    messages.remove(at: index)
                } else {
                    var updated = messages[index]
                    updated.isStreaming = false
                    messages[index] = updated
                }
                
                currentAssistantMessage = nil
                outputBuffer = ""
            }
        }
    }

    private func startPinging() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.send(.ping)
        }
    }

    private func stripAnsiCodes(_ string: String) -> String {
        var result = string
        
        // ANSI escape sequences (colors, cursor, etc.)
        let patterns = [
            "\u{1b}\\[[0-9;]*[a-zA-Z]",       // CSI sequences like [0m, [32m
            "\u{1b}\\][^\u{07}]*\u{07}",      // OSC sequences
            "\u{1b}[()][AB012]",              // Character set
            "\u{1b}\\[\\?[0-9;]*[hl]",        // Private modes
            "\u{1b}=",                         // Application keypad
            "\u{07}",                          // Bell
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
        
        // Replace carriage return with newline for proper line breaks
        result = result.replacingOccurrences(of: "\r\n", with: "\n")
        result = result.replacingOccurrences(of: "\r", with: "\n")
        
        // Clean up multiple newlines
        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        
        return result
    }
}
