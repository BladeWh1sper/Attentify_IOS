//
//  LessonMapper.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

extension LessonDTO {
    func toDomain() -> Lesson {
        let time = "\(lessonPeriod.startTime) — \(lessonPeriod.endTime)"
        let subject = LocalizedField(ru: subjectInfo.name.ru, en: subjectInfo.name.en)
        let type = LocalizedField(ru: lessonType.name.ru, en: lessonType.name.en)

        // Преподаватель в формате "Фамилия И. О."
        let teacherRu = Self.makeShortFIO(
            last: teacherInfo.lastName.ru,
            first: teacherInfo.firstName.ru,
            patronymic: teacherInfo.patronymic.ru
        )
        let teacherEn = Self.makeShortFIO(
            last: teacherInfo.lastName.en,
            first: teacherInfo.firstName.en,
            patronymic: teacherInfo.patronymic.en
        )
        let teacher = LocalizedField(ru: teacherRu, en: teacherEn)

        let classroom = "\(location.site.name.ru)-\(location.roomNumber)"

        let groupsFields: [LocalizedField] = (groups ?? []).map {
            LocalizedField(ru: $0.name.ru, en: $0.name.en)
        }

        return Lesson(
            id: id,
            lessonNumber: lessonPeriod.lessonNumber,
            time: time,
            subject: subject,
            type: type,
            teacher: teacher,
            classroom: classroom,
            groups: groupsFields,
            isVirtual: location.isVirtual ?? false
        )
    }

    private static func makeShortFIO(last: String, first: String, patronymic: String) -> String {
        let firstInitial = first.first.map { "\($0)." } ?? ""
        let patronymicInitial = patronymic.first.map { "\($0)." } ?? ""
        let space1 = firstInitial.isEmpty ? "" : " "
        let space2 = patronymicInitial.isEmpty ? "" : " "
        return "\(last)\(space1)\(firstInitial)\(space2)\(patronymicInitial)".trimmingCharacters(in: .whitespaces)
    }
}
