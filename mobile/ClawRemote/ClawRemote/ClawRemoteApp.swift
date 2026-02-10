import SwiftUI

@main
struct ClawRemoteApp: App {
    @StateObject private var connection = ConnectionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connection)
                .preferredColorScheme(.dark)
        }
    }
}
