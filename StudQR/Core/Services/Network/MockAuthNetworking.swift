//
//  MockAuthNetworking.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

struct MockAuthNetworking: AuthNetworking {
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Успех через 0.5 сек
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success("mock-token-123"))
        }
    }

    func fetchProfile(token: String, completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        let profile = ProfileResponse(
            id: 1,
            email: "demo@example.com",
            is_superuser: false,
            profile: ProfileInfo(
                id: 1,
                first_name: LocalizedField(ru: "Иван", en: "Ivan"),
                last_name:  LocalizedField(ru: "Иванов", en: "Ivanov"),
                patronymic: LocalizedField(ru: "Иванович", en: "Ivanovich"),
                phone: "+7 000 000 00 00"
            ),
            role: Role(id: 1, name: LocalizedField(ru: "Студент", en: "Student"),
                       description: LocalizedFieldOptional(ru: "Тест", en: "Test")),
            groups: []
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion(.success(profile))
        }
    }

    func fetchSchedule(token: String, date: Date, completion: @escaping ([Lesson]) -> Void) {
        let lessons: [Lesson] = [
            Lesson(id: 1, lessonNumber: 1, time: "09:00 — 10:35",
                   subject: LocalizedField(ru: "Математика", en: "Math"),
                   type: LocalizedField(ru: "Лекция", en: "Lecture"),
                   teacher: LocalizedField(ru: "Петров П. П.", en: "Petrov P.P."),
                   classroom: "A-101"),
            Lesson(id: 2, lessonNumber: 2, time: "10:50 — 12:25",
                   subject: LocalizedField(ru: "Математика", en: "Math"),
                   type: LocalizedField(ru: "Лекция", en: "Lecture"),
                   teacher: LocalizedField(ru: "Петров П. П.", en: "Petrov P.P."),
                   classroom: "A-101")
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(lessons)
        }
    }

    func confirmAttendance(token: String, code: String, completion: @escaping (AttendanceStatus) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion(.success)
        }
    }
}
