//
//  WebViewStore.swift
//  webview-temp
//
//  Created by Ash on 08/12/2024.
//

import Foundation
import WebKit
import Combine

class WebViewStore: ObservableObject {
    @Published var webView: WKWebView?
    @Published var urlString: String = ""
    @Published var pageTitle: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    var url: URL? {
        URL(string: urlString)
    }
    
    func updateResolution(_ resolution: Int) {
        let script = """
            var meta = document.querySelector('meta[name="viewport"]');
            if (meta) {
                meta.content = 'width=\(resolution)';
            } else {
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=\(resolution)';
                document.getElementsByTagName('head')[0].appendChild(meta);
            }
        """
        webView?.evaluateJavaScript(script)
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }
    
    func loadUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView?.load(request)
        }
    }
}
