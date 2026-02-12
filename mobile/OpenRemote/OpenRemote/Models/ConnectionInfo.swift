import Foundation

struct ConnectionInfo: Codable {
    let url: String
    let token: String
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "savedConnection")
        }
    }
    
    static func load() -> ConnectionInfo? {
        guard let data = UserDefaults.standard.data(forKey: "savedConnection"),
              let info = try? JSONDecoder().decode(ConnectionInfo.self, from: data) else {
            return nil
        }
        return info
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: "savedConnection")
    }
}

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case authenticating
    case connected
    case failed(String)
}

enum OutgoingMessage {
    case auth(token: String)
    case createSession(cols: Int, rows: Int)
    case input(sessionId: String, data: String)
    case resize(sessionId: String, cols: Int, rows: Int)
    case kill(sessionId: String)
    case ping
    case startPreview(port: Int)
    case stopPreview

    func toJSON() -> String {
        var dict: [String: Any] = [:]
        switch self {
        case .auth(let token):
            dict = ["type": "auth", "token": token, "name": "claw-ios"]
        case .createSession(let cols, let rows):
            dict = ["type": "create_session", "cols": cols, "rows": rows]
        case .input(let sessionId, let data):
            dict = ["type": "input", "sessionId": sessionId, "data": data]
        case .resize(let sessionId, let cols, let rows):
            dict = ["type": "resize", "sessionId": sessionId, "cols": cols, "rows": rows]
        case .kill(let sessionId):
            dict = ["type": "kill", "sessionId": sessionId]
        case .ping:
            dict = ["type": "ping"]
        case .startPreview(let port):
            dict = ["type": "start_preview", "port": port]
        case .stopPreview:
            dict = ["type": "stop_preview"]
        }
        let data = try! JSONSerialization.data(withJSONObject: dict)
        return String(data: data, encoding: .utf8)!
    }
}

enum IncomingMessage {
    case authOk
    case sessionCreated(sessionId: String)
    case output(sessionId: String, data: String)
    case sessionEnded(sessionId: String, exitCode: Int)
    case sessions([String])
    case pong
    case error(String)
    case previewReady(url: String, port: Int)
    case previewError(message: String)
    case previewStopped
    case unknown

    static func parse(_ text: String) -> IncomingMessage {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return .unknown
        }

        switch type {
        case "auth_ok":
            return .authOk
        case "session_created":
            return .sessionCreated(sessionId: json["sessionId"] as? String ?? "")
        case "output":
            return .output(
                sessionId: json["sessionId"] as? String ?? "",
                data: json["data"] as? String ?? ""
            )
        case "session_ended":
            return .sessionEnded(
                sessionId: json["sessionId"] as? String ?? "",
                exitCode: json["exitCode"] as? Int ?? -1
            )
        case "sessions":
            return .sessions(json["sessions"] as? [String] ?? [])
        case "pong":
            return .pong
        case "error":
            return .error(json["message"] as? String ?? "Unknown error")
        case "preview_ready":
            return .previewReady(
                url: json["url"] as? String ?? "",
                port: json["port"] as? Int ?? 3000
            )
        case "preview_error":
            return .previewError(message: json["message"] as? String ?? "Preview failed")
        case "preview_stopped":
            return .previewStopped
        default:
            return .unknown
        }
    }
}
