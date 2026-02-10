import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connection: ConnectionManager
    @State private var showScanner = false
    @State private var connectionInfo: ConnectionInfo?

    var body: some View {
        Group {
            switch connection.state {
            case .disconnected, .failed:
                HomeView(showScanner: $showScanner)
            case .connecting, .authenticating:
                ConnectingView()
            case .connected:
                ChatView()
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerView { info in
                showScanner = false
                connection.connect(info: info)
            }
        }
        .onAppear {
            // Auto-connect if we have saved connection
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
