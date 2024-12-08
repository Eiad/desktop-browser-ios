//
//  ContentView.swift
//  webview-temp
//
//  Created by Ash on 08/12/2024.
//

import SwiftUI
import SwiftData
import WebKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var urlString: String = "https://www.example.com"
    @State private var webViewStore = WebViewStore()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter URL", text: $urlString, onCommit: loadURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            Group {
                                if !urlString.isEmpty {
                                    Button(action: {
                                        urlString = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            },
                            alignment: .trailing
                        )
                    
                }
                .padding()

                WebView(url: URL(string: urlString) ?? URL(string: "https://www.example.com")!)
                    .environmentObject(webViewStore)
            }
            .navigationTitle("VibeBrowse")
            .font(.system(size: 18))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        webViewStore.goBack()
                    }) {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(!webViewStore.canGoBack)
                    
                    Button(action: {
                        webViewStore.goForward()
                    }) {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(!webViewStore.canGoForward)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        webViewStore.webView?.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    private func loadURL() {
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class WebViewStore: ObservableObject {
    weak var webView: WKWebView?
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
