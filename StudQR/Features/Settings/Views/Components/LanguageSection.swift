//
//  LanguageSection.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct LanguageSection: View {
    @Binding var selectedLanguage: String

    var body: some View {
        Section(header: Text(localized("language_section"))
            .foregroundColor(.secondaryText)) {
            Picker(localized("language_picker"), selection: $selectedLanguage) {
                Text("🇷🇺 Русский").tag("ru")
                Text("🇺🇸 English").tag("en")
            }
            .pickerStyle(.segmented)
            .foregroundColor(.primaryText)
        }
    }

    private func localized(_ key: String) -> String {
        let lang = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: lang, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
