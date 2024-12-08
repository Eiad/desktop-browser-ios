import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @EnvironmentObject var webViewStore: WebViewStore
    
    func makeCoordinator() -> Coordinator {
        Coordinator(webViewStore: webViewStore)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webViewStore.webView = webView
        
        // Set custom user agent to request desktop site
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Version/15.0 Safari/605.1.15"
        
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
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        // Create new webview with configuration
        let configuredWebView = WKWebView(frame: .zero, configuration: configuration)
        webViewStore.webView = configuredWebView
        
        // Load the initial URL
        let request = URLRequest(url: url)
        configuredWebView.load(request)
        
        return configuredWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var webViewStore: WebViewStore
        
        init(webViewStore: WebViewStore) {
            self.webViewStore = webViewStore
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewStore.canGoBack = webView.canGoBack
            webViewStore.canGoForward = webView.canGoForward
        }
    }
}