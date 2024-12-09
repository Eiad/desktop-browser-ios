//
//  Bookmark.swift
//  webview-temp
//
//  Created by Ash on 09/12/2024.
//

import Foundation
import SwiftData

@Model
final class Bookmark {
    var title: String
    var url: String
    var timestamp: Date

    init(title: String, url: String, timestamp: Date = Date()) {
        self.title = title
        self.url = url
        self.timestamp = timestamp
    }
}
