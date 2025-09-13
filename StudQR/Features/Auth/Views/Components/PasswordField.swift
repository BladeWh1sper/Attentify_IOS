//
//  PasswordField.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

/// Универсальное поле пароля с переключателем видимости
struct PasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        HStack {
            if isVisible {
                TextField(title, text: $text)
                    .foregroundColor(.primaryText)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            } else {
                SecureField(title, text: $text)
                    .foregroundColor(.primaryText)
                    .textContentType(.password)
            }

            Button(action: { isVisible.toggle() }) {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundColor(.secondaryText)
            }
            .accessibilityLabel(isVisible ? "Hide password" : "Show password")
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondaryText.opacity(0.3), lineWidth: 1)
        )
    }
}
