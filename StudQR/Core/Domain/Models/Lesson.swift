//
//  Lesson.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import Foundation

public struct Lesson: Identifiable, Equatable, Hashable {
    public let id: Int
    public let lessonNumber: Int
    public let time: String
    public let subject: LocalizedField
    public let type: LocalizedField
    public let teacher: LocalizedField
    public let classroom: String

    public let groups: [LocalizedField]
    public let isVirtual: Bool

    public init(
        id: Int,
        lessonNumber: Int,
        time: String,
        subject: LocalizedField,
        type: LocalizedField,
        teacher: LocalizedField,
        classroom: String,
        groups: [LocalizedField] = [],
        isVirtual: Bool = false
    ) {
        self.id = id
        self.lessonNumber = lessonNumber
        self.time = time
        self.subject = subject
        self.type = type
        self.teacher = teacher
        self.classroom = classroom
        self.groups = groups
        self.isVirtual = isVirtual
    }
}
