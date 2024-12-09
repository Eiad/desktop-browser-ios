//
//  BookmarksView.swift
//  webview-temp
//
//  Created by Ash on 09/12/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct BookmarksView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bookmark.timestamp, order: .reverse) private var bookmarks: [Bookmark]
    @Binding var selectedURL: String
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarks) { bookmark in
                    Button(action: {
                        selectedURL = bookmark.url
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bookmark.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(bookmark.url)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteBookmarks)
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteBookmarks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(bookmarks[index])
        }
    }
}
