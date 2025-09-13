//
//  LocalizedField.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

public struct LocalizedField: Codable, Equatable, Hashable {
    public let ru: String
    public let en: String

    public init(ru: String, en: String) {
        self.ru = ru
        self.en = en
    }
}
