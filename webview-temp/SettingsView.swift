//
//  SettingsView.swift
//  webview-temp
//
//  Created by Ash on 10/12/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [Settings]
    @EnvironmentObject var webViewStore: WebViewStore
    
    @State private var screenResolution: String = "1200"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Browser Settings")) {
                    TextField("Screen Resolution", text: $screenResolution)
                        .keyboardType(.numberPad)
                        .onAppear {
                            if let setting = settings.first {
                                screenResolution = "\(setting.screenResolution)"
                            }
                        }
                }
                
                Section {
                    NavigationLink(destination: BookmarksView(selectedURL: $webViewStore.urlString)) {
                        Text("Bookmarks")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSettings() {
        if let resolution = Int(screenResolution) {
            if let setting = settings.first {
                setting.screenResolution = resolution
            } else {
                let setting = Settings(screenResolution: resolution)
                modelContext.insert(setting)
            }
            
            webViewStore.updateResolution(resolution)
        }
    }
}
