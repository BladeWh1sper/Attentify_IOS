//
//  Schedule.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import Foundation

/// Доменная модель расписания: ключ — строка-дата от API ("2025-03-29")
public struct Schedule: Equatable, Hashable {
    public let days: [String: [Lesson]]

    public init(days: [String: [Lesson]]) {
        self.days = days
    }
}
