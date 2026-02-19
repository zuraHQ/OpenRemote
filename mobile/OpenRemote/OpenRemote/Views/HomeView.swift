import SwiftUI

struct HomeView: View {
    @EnvironmentObject var connection: ConnectionManager
    @Binding var showScanner: Bool
    @State private var manualURL = ""
    @State private var manualToken = ""
    @State private var showManual = false
    @State private var hasDesktopApp = false

    var body: some View {
        NavigationStack {
            if !hasDesktopApp {
                downloadStep
            } else {
                connectStep
            }
        }
    }

 

    private var downloadStep: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image("Vector")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("OpenRemote")
                    .font(.title.bold())

                Text("Control Claude from your iPhone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "desktopcomputer")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Desktop app required")
                            .font(.subheadline.bold())
                        Text("Download and run OpenRemote on your Mac to get started.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                HStack(spacing: 12) {
                    Image(systemName: "qrcode")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scan to connect")
                            .font(.subheadline.bold())
                        Text("The desktop app will show a QR code. Scan it to pair.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                HStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Control Claude remotely")
                            .font(.subheadline.bold())
                        Text("Send prompts, see live activity, and preview from your phone.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 20) {
                Button {
                    if let url = URL(string: "https://github.com/zuraHQ/OpenRemote/releases") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Download Desktop App", systemImage: "arrow.down.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal, 40)

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasDesktopApp = true
                    }
                } label: {
                    Text("I already have the desktop app")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                .padding(.horizontal, 40)
            }

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }


    private var connectStep: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)

                Text("Scan QR Code")
                    .font(.title2.bold())

                Text("Open the desktop app and scan the\nQR code shown on your screen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            

            if case .failed(let msg) = connection.state {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    showScanner = true
                } label: {
                    Label("Scan QR Code", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal, 40)

                Button {
                    withAnimation { showManual.toggle() }
                } label: {
                    Text("Connect manually")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasDesktopApp = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
