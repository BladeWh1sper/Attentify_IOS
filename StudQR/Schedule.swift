//
//  Schedule.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import Foundation

struct Schedule: Decodable {
    let days: [String: [Lesson]]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode([String: [Lesson]?].self)
        self.days = raw.mapValues { $0 ?? [] }
    }
}
