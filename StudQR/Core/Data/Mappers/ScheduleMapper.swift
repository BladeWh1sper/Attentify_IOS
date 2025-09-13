//
//  Untitled.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

extension ScheduleDTO {
    func toDomain() -> Schedule {
        let mapped: [String: [Lesson]] = days.mapValues { list in
            list.map { $0.toDomain() }
        }
        return Schedule(days: mapped)
    }
}
