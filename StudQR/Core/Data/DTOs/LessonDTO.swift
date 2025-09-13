//
//  LessonDTO.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

struct LessonDTO: Decodable {
    let id: Int
    let lessonPeriod: LessonPeriod
    let subjectInfo: LocalizedNameBox
    let lessonType: LocalizedNameBox
    let teacherInfo: TeacherNameBox
    let location: LocationBox

    enum CodingKeys: String, CodingKey {
        case id
        case lessonPeriod = "lesson_period"
        case subjectInfo = "subject"
        case lessonType = "lesson_type"
        case teacherInfo = "teacher"
        case location
    }

    struct LessonPeriod: Decodable {
        let lessonNumber: Int
        let startTime: String
        let endTime: String
        enum CodingKeys: String, CodingKey {
            case lessonNumber = "lesson_number"
            case startTime = "start_time"
            case endTime = "end_time"
        }
    }

    struct LocalizedNameBox: Decodable {
        let name: Lang
        struct Lang: Decodable { let ru: String; let en: String }
    }

    struct TeacherNameBox: Decodable {
        let firstName: Lang
        let lastName: Lang
        let patronymic: Lang
        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case patronymic
        }
        struct Lang: Decodable { let ru: String; let en: String }
    }

    struct LocationBox: Decodable {
        let site: Site
        let roomNumber: String
        enum CodingKeys: String, CodingKey {
            case site
            case roomNumber = "room_number"
        }
        struct Site: Decodable {
            let name: Lang
            struct Lang: Decodable { let ru: String; let en: String }
        }
    }
}
