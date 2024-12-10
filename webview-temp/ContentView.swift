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
    @StateObject private var webViewStore = WebViewStore()
    @State private var isShowingBookmarks = false
    @State private var isShowingSettings = false

    private func formatURL(_ input: String) -> String {
        // Trim whitespace and convert to lowercase
        var formattedURL = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Check if it's a search query
        if formattedURL.contains(" ") || !formattedURL.contains(".") {
            // Replace spaces with plus signs for search
            let searchQuery = formattedURL.replacingOccurrences(of: " ", with: "+")
            return "https://www.google.com/search?q=\(searchQuery)"
        }
        
        // If it's already a valid URL with scheme, return as is
        if formattedURL.hasPrefix("http://") || formattedURL.hasPrefix("https://") {
            return formattedURL
        }
        
        // Remove any "www." prefix if present
        if formattedURL.hasPrefix("www.") {
            formattedURL = String(formattedURL.dropFirst(4))
        }
        
        // Handle common TLDs without dots (like "amazon" -> "amazon.com")
        let commonSites = ["google", "facebook", "twitter", "amazon", "youtube", "instagram"]
        if !formattedURL.contains(".") {
            if commonSites.contains(formattedURL) {
                formattedURL += ".com"
            }
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
        NavigationStack {
            VStack(spacing: 0) {
                // Combined Header with Search Bar
                HStack(spacing: 12) {
                    // Back/Forward Navigation
                    HStack(spacing: 16) {
                        Button(action: { webViewStore.goBack() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(webViewStore.canGoBack ? Color("AccentColor") : .gray)
                        }
                        .disabled(!webViewStore.canGoBack)
                        
                        Button(action: { webViewStore.goForward() }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(webViewStore.canGoForward ? Color("AccentColor") : .gray)
                        }
                        .disabled(!webViewStore.canGoForward)
                    }
                    .font(.system(size: 16, weight: .medium))
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        
                        TextField("Search or enter URL", text: $webViewStore.urlString)
                            .font(.system(size: 14))
                            .submitLabel(.go)
                            .onSubmit { loadURL() }
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                        
                        if !webViewStore.urlString.isEmpty {
                            Button(action: { webViewStore.urlString = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Right Actions
                    HStack(spacing: 16) {
                        Button(action: { webViewStore.webView?.reload() }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color("AccentColor"))
                        }
                        
                        Button(action: { addBookmark() }) {
                            Image(systemName: "bookmark")
                                .foregroundColor(Color("AccentColor"))
                        }
                        
                        Button(action: { isShowingSettings = true }) {
                            Image(systemName: "gear")
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                    .font(.system(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
                
                // Web Content
                WebView()
                    .environmentObject(webViewStore)
            }
            .sheet(isPresented: $isShowingBookmarks) {
                BookmarksView(selectedURL: $webViewStore.urlString)
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
                    .environmentObject(webViewStore)
            }
        }
    }

    private func addBookmark() {
        guard !webViewStore.urlString.isEmpty else { return }
        let title = webViewStore.pageTitle.isEmpty ? webViewStore.urlString : webViewStore.pageTitle
        let bookmark = Bookmark(title: title, url: webViewStore.urlString)
        modelContext.insert(bookmark)
        
        // Show feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
