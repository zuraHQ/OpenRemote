import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connection: ConnectionManager
    @State private var showScanner = false
    @State private var hasConnected = false

    var body: some View {
        Group {
            if hasConnected && !connection.didExplicitlyDisconnect {
                ChatView()
            } else {
                switch connection.state {
                case .disconnected, .failed:
                    HomeView(showScanner: $showScanner)
                case .connecting, .authenticating:
                    ConnectingView()
                case .connected:
                    ChatView()
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerView { info in
                showScanner = false
                connection.connect(info: info)
            }
        }
        .onChange(of: connection.state) {
            if connection.state == .connected {
                hasConnected = true
            }
        }
        .onAppear {
            if connection.state == .disconnected, let saved = ConnectionInfo.load() {
                connection.connect(info: saved)
            }
        }
    }
}

struct ConnectingView: View {
    @EnvironmentObject var connection: ConnectionManager

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(connection.state == .authenticating ? "Authenticating..." : "Connecting...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
