//
//  Lesson.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import Foundation

struct Lesson: Identifiable, Decodable {
    let id: Int
    let lessonNumber: Int
    let time: String
    let subject: LocalizedField
    let type: LocalizedField
    let teacher: LocalizedField
    let classroom: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case lessonPeriod = "lesson_period"
        case subjectInfo = "subject"
        case lessonType = "lesson_type"
        case teacherInfo = "teacher"
        case location
    }

    enum LessonPeriodKeys: String, CodingKey {
        case lessonNumber = "lesson_number"
        case startTime = "start_time"
        case endTime = "end_time"
    }

    enum NameKeys: String, CodingKey {
        case name
    }

    enum NameLangKeys: String, CodingKey {
        case ru
        case en
    }

    enum TeacherNameKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case patronymic
    }

    enum SiteKeys: String, CodingKey {
        case site
        case roomNumber = "room_number"
    }

    enum SiteInnerKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)

        // Lesson period (time and number)
        let period = try container.nestedContainer(keyedBy: LessonPeriodKeys.self, forKey: .lessonPeriod)
        lessonNumber = try period.decode(Int.self, forKey: .lessonNumber)
        let startTime = try period.decode(String.self, forKey: .startTime)
        let endTime = try period.decode(String.self, forKey: .endTime)
        time = "\(startTime) — \(endTime)"

        // Subject name (LocalizedField)
        let subjectContainer = try container.nestedContainer(keyedBy: NameKeys.self, forKey: .subjectInfo)
        let subjectNameContainer = try subjectContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .name)
        let subjectRu = try subjectNameContainer.decode(String.self, forKey: .ru)
        let subjectEn = try subjectNameContainer.decode(String.self, forKey: .en)
        subject = LocalizedField(ru: subjectRu, en: subjectEn)

        // Lesson type (LocalizedField)
        let typeContainer = try container.nestedContainer(keyedBy: NameKeys.self, forKey: .lessonType)
        let typeNameContainer = try typeContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .name)
        let typeRu = try typeNameContainer.decode(String.self, forKey: .ru)
        let typeEn = try typeNameContainer.decode(String.self, forKey: .en)
        type = LocalizedField(ru: typeRu, en: typeEn)

        // Teacher name (LocalizedField)
        let teacherContainer = try container.nestedContainer(keyedBy: TeacherNameKeys.self, forKey: .teacherInfo)
        let lastRu = try teacherContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .lastName).decode(String.self, forKey: .ru)
        let lastEn = try teacherContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .lastName).decode(String.self, forKey: .en)
        let firstRu = try teacherContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .firstName).decode(String.self, forKey: .ru)
        let firstEn = try teacherContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .firstName).decode(String.self, forKey: .en)
        let patronymicRu = try teacherContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .patronymic).decode(String.self, forKey: .ru)
        let patronymicEn = try teacherContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .patronymic).decode(String.self, forKey: .en)

        let teacherRu = "\(lastRu) \(firstRu.first.map { "\($0)." } ?? "") \(patronymicRu.first.map { "\($0)." } ?? "")"
        let teacherEn = "\(lastEn) \(firstEn.first.map { "\($0)." } ?? "") \(patronymicEn.first.map { "\($0)." } ?? "")"
        teacher = LocalizedField(ru: teacherRu, en: teacherEn)

        // Classroom (пока только ru)
        let locationContainer = try container.nestedContainer(keyedBy: SiteKeys.self, forKey: .location)
        let siteContainer = try locationContainer.nestedContainer(keyedBy: SiteInnerKeys.self, forKey: .site)
        let buildingRu = try siteContainer.nestedContainer(keyedBy: NameLangKeys.self, forKey: .name).decode(String.self, forKey: .ru)
        let room = try locationContainer.decode(String.self, forKey: .roomNumber)
        classroom = "\(buildingRu)-\(room)"
    }

    init(id: Int, lessonNumber: Int, time: String, subject: LocalizedField, type: LocalizedField, teacher: LocalizedField, classroom: String) {
        self.id = id
        self.lessonNumber = lessonNumber
        self.time = time
        self.subject = subject
        self.type = type
        self.teacher = teacher
        self.classroom = classroom
    }
}
