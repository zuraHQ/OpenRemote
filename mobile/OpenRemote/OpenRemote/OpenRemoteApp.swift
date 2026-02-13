import SwiftUI
import RevenueCat

@main
struct OpenRemoteApp: App {
    @StateObject private var connection = ConnectionManager()

    init() {
        Purchases.configure(withAPIKey: "YOUR_REVENUECAT_API_KEY")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connection)
                .preferredColorScheme(.dark)
        }
    }
}
