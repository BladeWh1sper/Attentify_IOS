//
//  StudQRApp.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import SwiftUI

@main
struct StudQRApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
