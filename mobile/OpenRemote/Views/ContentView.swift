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
                TerminalView()
            }
        }
        .sheet(isPresented: $showScanner) {
            ScannerView { info in
                showScanner = false
                connection.connect(info: info)
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
