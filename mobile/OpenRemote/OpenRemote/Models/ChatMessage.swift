import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: Role
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    var toolActivity: String?
    var isQueued: Bool
    
    enum Role {
        case user
        case assistant
        case system
    }
    
    init(role: Role, content: String, isStreaming: Bool = false, toolActivity: String? = nil, isQueued: Bool = false) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.isStreaming = isStreaming
        self.toolActivity = toolActivity
        self.isQueued = isQueued
    }
}
