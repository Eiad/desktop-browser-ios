//
//  Settings.swift
//  webview-temp
//
//  Created by Ash on 10/12/2024.
//

import Foundation
import SwiftData

@Model
final class Settings {
    var screenResolution: Int
    
    init(screenResolution: Int = 1200) {
        self.screenResolution = screenResolution
    }
}
