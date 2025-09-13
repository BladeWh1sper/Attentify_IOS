//
//  ThemeManager.swift
//  StudQR
//
//  Created by Andrew Belik on 5/26/25.
//

import SwiftUI

final class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = "system" {
        didSet {
            objectWillChange.send()
        }
    }

    /// Определяет активную цветовую схему для всего приложения.
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil    // system
        }
    }
}

#Preview("ThemeManager - Light") {
    ContentView()
        .environmentObject(AuthViewModel(api: MockAuthNetworking()))
        .environmentObject({
            let tm = ThemeManager()
            tm.selectedTheme = "light"
            return tm
        }())
}

#Preview("ThemeManager - Dark") {
    ContentView()
        .environmentObject(AuthViewModel(api: MockAuthNetworking()))
        .environmentObject({
            let tm = ThemeManager()
            tm.selectedTheme = "dark"
            return tm
        }())
}
