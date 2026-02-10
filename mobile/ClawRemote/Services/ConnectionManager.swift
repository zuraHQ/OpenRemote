import Foundation
import Combine

@MainActor
class ConnectionManager: ObservableObject {
    @Published var state: ConnectionState = .disconnected
    @Published var terminalOutput: String = ""
    @Published var sessionId: String?
    @Published var activeSessions: [String] = []

    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession?
    private var token: String?
    private var pingTimer: Timer?

    func connect(info: ConnectionInfo) {
        disconnect()
        token = info.token

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

    func disconnect() {
        pingTimer?.invalidate()
        pingTimer = nil
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        session?.invalidateAndCancel()
        session = nil
        sessionId = nil
        state = .disconnected
    }

    func createSession() {
        send(.createSession(cols: 80, rows: 24))
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

        case .output(_, let data):
            terminalOutput += data

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

    private func startPinging() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.send(.ping)
        }
    }
}
