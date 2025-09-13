//
//  ScheduleDTO.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

/// DTO под ответ API, где дни приходят мапой: "YYYY-MM-DD": [LessonDTO]?
struct ScheduleDTO: Decodable {
    let days: [String: [LessonDTO]]

    init(from decoder: Decoder) throws {
        // Ответ сервера — single-value контейнер с мапой "date" -> [LessonDTO]?
        let container = try decoder.singleValueContainer()
        let raw = try container.decode([String: [LessonDTO]?].self)
        // Заменяем nil на []
        self.days = raw.mapValues { $0 ?? [] }
    }
}
