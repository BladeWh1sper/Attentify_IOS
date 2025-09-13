//
//  AuthViewModel+Localization.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

extension AuthViewModel {
    func localized(_ field: LocalizedField) -> String {
        selectedLanguage == "en" ? field.en : field.ru
    }

    func localized(_ field: LocalizedFieldOptional) -> String {
        if selectedLanguage == "en" {
            return field.en ?? ""
        } else {
            return field.ru ?? ""
        }
    }
}
