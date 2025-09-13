//
//  ThemeSection.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct ThemeSection: View {
    @Binding var selectedTheme: String
    let localized: (String) -> String

    var body: some View {
        Section(header: Text(localized("theme_section"))
            .foregroundColor(.secondaryText)) {
            Picker(localized("theme_picker"), selection: $selectedTheme) {
                Text(localized("theme_light")).tag("light")
                Text(localized("theme_dark")).tag("dark")
                Text(localized("theme_system")).tag("system")
            }
            .pickerStyle(.segmented)
            .foregroundColor(.primaryText)
        }
    }
}
