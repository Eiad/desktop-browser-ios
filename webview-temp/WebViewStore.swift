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
    weak var webView: WKWebView?

    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var urlString: String = "https://www.example.com"

    var url: URL? {
        URL(string: urlString)
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
