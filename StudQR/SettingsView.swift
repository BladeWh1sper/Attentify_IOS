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
                Color.appBackground
                    .ignoresSafeArea()

                Form {
                    Section(header: Text(localized("language_section"))
                        .foregroundColor(Color.secondaryText)) {
                        Picker(localized("language_picker"), selection: $selectedLanguage) {
                            Text("🇷🇺 Русский").tag("ru")
                            Text("🇺🇸 English").tag("en")
                        }
                        .pickerStyle(.segmented)
                        .foregroundColor(Color.primaryText)
                    }

                    Section(header: Text(localized("theme_section"))
                        .foregroundColor(Color.secondaryText)) {
                        Picker(localized("theme_picker"), selection: $themeManager.selectedTheme) {
                            Text(localized("theme_light")).tag("light")
                            Text(localized("theme_dark")).tag("dark")
                            Text(localized("theme_system")).tag("system")
                        }
                        .pickerStyle(.segmented)
                        .foregroundColor(Color.primaryText)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(localized("settings_title"))
            .foregroundColor(Color.primaryText)
        }
    }

    func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
