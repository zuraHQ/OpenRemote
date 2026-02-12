import SwiftUI
import WebKit

struct PreviewView: View {
    let url: String
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            WebView(url: URL(string: url)!)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.primary)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Link(destination: URL(string: url)!) {
                            Image(systemName: "safari")
                                .foregroundStyle(.orange)
                        }
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        // Allow loading from any source including localhost/HTTP
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.isInspectable = true

        // Load once here in makeUIView
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Don't reload — the page was already loaded in makeUIView
    }
}
