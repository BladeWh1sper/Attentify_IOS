//
//  LessonRow.swift
//  StudQR
//
//  Created by Andrew Belik on 30.03.2025.
//

import SwiftUI

struct LessonRow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"
    let lesson: Lesson

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(lesson.lessonNumber) \(localized("lesson_number")) — \(lesson.time)")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)

                Text(authViewModel.localized(lesson.subject))
                    .font(.headline)
                    .foregroundColor(.primaryText)

                Text(authViewModel.localized(lesson.type))
                    .font(.caption)
                    .foregroundColor(.secondaryText)

                Text(authViewModel.localized(lesson.teacher))
                    .font(.caption)
                    .foregroundColor(.blue)

                Text("\(localized("classroom")): \(lesson.classroom)")
                    .font(.caption2)
                    .foregroundColor(.secondaryText)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondaryText.opacity(0.2))
        )
    }

    func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    LessonRow(lesson: Lesson(
        id: 1,
        lessonNumber: 2,
        time: "10:50 — 12:25",
        subject: LocalizedField(ru: "Параллельное и многопоточное программирование", en: "Parallel and Multithreaded Programming"),
        type: LocalizedField(ru: "Лекция", en: "Lecture"),
        teacher: LocalizedField(ru: "Панкрушин П. Ю.", en: "Pankrushin P.Y."),
        classroom: "Л-550"
    ))
    .environmentObject(AuthViewModel())
}
