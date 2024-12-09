import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @EnvironmentObject var webViewStore: WebViewStore

    func makeCoordinator() -> Coordinator {
        Coordinator(webViewStore: webViewStore)
    }

    func makeUIView(context: Context) -> WKWebView {
        // Create a WKWebViewConfiguration with the userContentController
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()

        // Configure viewport width
        let script = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=1200';
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(userScript)
        configuration.userContentController = userContentController

        // Create new webview with configuration
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Version/15.0 Safari/605.1.15"
        webView.navigationDelegate = context.coordinator

        webViewStore.webView = webView

        // Load the initial URL
        if let url = webViewStore.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Do not reload the web view to avoid interfering with navigation
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var webViewStore: WebViewStore

        init(webViewStore: WebViewStore) {
            self.webViewStore = webViewStore
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewStore.canGoBack = webView.canGoBack
            webViewStore.canGoForward = webView.canGoForward

            // Update the urlString in webViewStore
            webViewStore.urlString = webView.url?.absoluteString ?? ""
        }
    }
}