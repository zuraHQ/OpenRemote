import SwiftUI
import AVFoundation

struct ScannerView: View {
    let onScan: (ConnectionInfo) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var scanned = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                QRScannerRepresentable { code in
                    guard !scanned else { return }
                    handleScan(code)
                }
                .ignoresSafeArea()

                // Overlay with cutout
                VStack {
                    Spacer()

                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.green, lineWidth: 3)
                        .frame(width: 250, height: 250)

                    Spacer().frame(height: 40)

                    Text("Point at the QR code on your desktop")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))

                    if let error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func handleScan(_ code: String) {
        guard let data = code.data(using: .utf8),
              let info = try? JSONDecoder().decode(ConnectionInfo.self, from: data) else {
            error = "Invalid QR code — not a Claw Remote code"
            // Reset after a moment so they can try again
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { error = nil }
            return
        }

        scanned = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onScan(info)
    }
}

// UIKit wrapper for the camera-based QR scanner
struct QRScannerRepresentable: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerVC {
        let vc = QRScannerVC()
        vc.onCode = onCode
        return vc
    }

    func updateUIViewController(_ vc: QRScannerVC, context: Context) {}
}

class QRScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCode: ((String) -> Void)?
    private let captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        captureSession.addInput(input)

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput results: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let readable = results.first as? AVMetadataMachineReadableCodeObject,
              let code = readable.stringValue else { return }
        onCode?(code)
    }
}
