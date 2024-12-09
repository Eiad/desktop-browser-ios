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
    @StateObject private var webViewStore = WebViewStore()
    
    private func formatURL(_ input: String) -> String {
        var formattedURL = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // If it's already a valid URL with scheme, return as is
        if formattedURL.hasPrefix("http://") || formattedURL.hasPrefix("https://") {
            return formattedURL
        }
        
        // Remove any "www." prefix if present
        if formattedURL.hasPrefix("www.") {
            formattedURL = String(formattedURL.dropFirst(4))
        }
        
        // Add https:// prefix
        return "https://\(formattedURL)"
    }
    
    private func loadURL() {
        let formattedURL = formatURL(webViewStore.urlString)
        if webViewStore.urlString != formattedURL {
            webViewStore.urlString = formattedURL
        }
        webViewStore.loadUrl(formattedURL)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Logo Section
                VStack(spacing: 8) {
                    Text("VibeBrowse")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AccentColor"), Color("AccentColor").opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.top, 16)                
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                
                // URL Bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                        
                        TextField("Search or enter URL", text: $webViewStore.urlString)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 16))
                            .submitLabel(.go)
                            .onSubmit {
                                loadURL()
                            }
                        
                        if !webViewStore.urlString.isEmpty {
                            Button(action: { webViewStore.urlString = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Navigation Bar
                HStack(spacing: 32) {
                    Button(action: { webViewStore.goBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(webViewStore.canGoBack ? Color("AccentColor") : .gray)
                    }
                    .disabled(!webViewStore.canGoBack)
                    
                    Button(action: { webViewStore.goForward() }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(webViewStore.canGoForward ? Color("AccentColor") : .gray)
                    }
                    .disabled(!webViewStore.canGoForward)
                    
                    Spacer()
                    
                    Button(action: { webViewStore.webView?.reload() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Web Content
                WebView()
                    .environmentObject(webViewStore)
            }
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
