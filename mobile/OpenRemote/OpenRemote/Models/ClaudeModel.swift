import Foundation

enum ClaudeModel: String, CaseIterable {
    case opus = "opus"
    case sonnet = "sonnet"
    
    var displayName: String {
        switch self {
        case .opus: return "Opus"
        case .sonnet: return "Sonnet"
        }
    }
    
    static func load() -> ClaudeModel {
        guard let raw = UserDefaults.standard.string(forKey: "claudeModel"),
              let model = ClaudeModel(rawValue: raw) else {
            return .sonnet
        }
        return model
    }
    
    func save() {
        UserDefaults.standard.set(rawValue, forKey: "claudeModel")
    }
}
