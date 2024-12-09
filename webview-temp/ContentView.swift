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
                            .font(.system(size: 16))
                            .submitLabel(.go)
                            .onSubmit {
                                loadURL()
                            }
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)

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
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        addBookmark()
                    }) {
                        Image(systemName: "bookmark.fill")
                    }
                    Button(action: {
                        isShowingBookmarks = true
                    }) {
                        Image(systemName: "book")
                    }
                }
            }
            .sheet(isPresented: $isShowingBookmarks) {
                BookmarksView(selectedURL: $webViewStore.urlString)
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
