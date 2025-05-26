//
//  ThemeManager.swift
//  StudQR
//
//  Created by Andrew Belik on 5/26/25.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = "system" {
        didSet {
            objectWillChange.send()
        }
    }
    
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}
