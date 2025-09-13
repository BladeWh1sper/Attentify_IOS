//
//  SettingsView.swift
//  StudQR
//
//  Created by Andrew Belik on 5/25/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                Form {
                    LanguageSection(selectedLanguage: $selectedLanguage)
                    ThemeSection(selectedTheme: $themeManager.selectedTheme,
                                 localized: localized)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(localized("settings_title"))
            .foregroundColor(.primaryText)
        }
    }

    // MARK: - Localization helper
    private func localized(_ key: String) -> String {
        let lang = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: lang, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
