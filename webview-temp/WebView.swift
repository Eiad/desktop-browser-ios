import SwiftUI
import WebKit
import SwiftData

struct WebView: UIViewRepresentable {
    @EnvironmentObject var webViewStore: WebViewStore
    @Query private var settings: [Settings]

    func makeCoordinator() -> Coordinator {
        Coordinator(webViewStore: webViewStore)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()

        let resolution = settings.first?.screenResolution ?? 1200
        let script = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=\(resolution)';
            document.getElementsByTagName('head')[0].appendChild(meta);
        """

        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(userScript)
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Version/15.0 Safari/605.1.15"
        webView.navigationDelegate = context.coordinator

        webViewStore.webView = webView

        // Load initial URL if available
        if let urlString = webViewStore.urlString.nilIfEmpty,
           let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // URL loading is handled in ContentView's loadURL() function
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var webViewStore: WebViewStore

        init(webViewStore: WebViewStore) {
            self.webViewStore = webViewStore
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewStore.canGoBack = webView.canGoBack
            webViewStore.canGoForward = webView.canGoForward
            webViewStore.pageTitle = webView.title ?? ""
            webViewStore.urlString = webView.url?.absoluteString ?? ""
        }
    }
}

// Helper extension
extension String {
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}