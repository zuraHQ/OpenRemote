import SwiftUI

struct HomeView: View {
    @EnvironmentObject var connection: ConnectionManager
    @Binding var showScanner: Bool
    @State private var manualURL = ""
    @State private var manualToken = ""
    @State private var showManual = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text(">_")
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)

                    Text("OpenRemote")
                        .font(.title.bold())

                    Text("Control your terminal from here")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if case .failed(let msg) = connection.state {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                Spacer()

                Button {
                    showScanner = true
                } label: {
                    Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.horizontal, 40)

                Button {
                    withAnimation { showManual.toggle() }
                } label: {
                    Text("Connect manually")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if showManual {
                    VStack(spacing: 12) {
                        TextField("Tunnel URL", text: $manualURL)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        SecureField("Pairing Token", text: $manualToken)
                            .textFieldStyle(.roundedBorder)

                        Button("Connect") {
                            let info = ConnectionInfo(url: manualURL, token: manualToken)
                            connection.connect(info: info)
                        }
                        .buttonStyle(.bordered)
                        .disabled(manualURL.isEmpty || manualToken.isEmpty)
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
