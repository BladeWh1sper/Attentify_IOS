//
//  TeacherLessonRow.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct TeacherLessonRow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"
    let lesson: Lesson

    @State private var showQR = false
    @State private var sessionKey: String?
    @State private var isCreating = false
    @State private var errorText: String?

    private var groupsText: String {
        let names = lesson.groups.map { authViewModel.localized($0) }
        return names.isEmpty ? "—" : names.joined(separator: ", ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(lesson.lessonNumber) \(localized("lesson_number")) — \(lesson.time)")
                    .font(.subheadline).foregroundColor(.secondaryText)

                Text(authViewModel.localized(lesson.subject))
                    .font(.headline).foregroundColor(.primaryText)

                Text(authViewModel.localized(lesson.type))
                    .font(.caption).foregroundColor(.secondaryText)

                Text("\(localized("groups")): \(groupsText)")
                    .font(.caption).foregroundColor(.blue)

                Text("\(localized("classroom")): \(lesson.classroom)\(lesson.isVirtual ? " · \(localized("virtual"))" : "")")
                    .font(.caption2).foregroundColor(.secondaryText)

                if let e = errorText {
                    Text(e).font(.caption2).foregroundColor(.red)
                }
            }

            Spacer()

            // ✅ Кнопка QR
            Button {
                createSessionAndShowQR()
            } label: {
                if isCreating {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Image(systemName: "qrcode")
                        .imageScale(.large)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .accessibilityLabel("Show QR")

        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondaryText.opacity(0.2))
        )
        .sheet(isPresented: $showQR) {
            if let key = sessionKey {
                // ⚠️ schedule_id — использую lesson.id как идентификатор пары.
                SessionQRScreen(sessionKey: key, scheduleId: lesson.id, teacherId: authViewModel.profile?.id ?? -1)
            } else {
                ProgressView("Готовим QR…").padding()
            }
        }
    }

    private func createSessionAndShowQR() {
        guard let token = authViewModel.token else { return }
        errorText = nil
        isCreating = true
        authViewModel.api.createSession(token: token) { result in
            DispatchQueue.main.async {
                isCreating = false
                switch result {
                case .success(let key):
                    self.sessionKey = key
                    self.showQR = true
                case .failure:
                    self.errorText = localized("error_generic")
                }
            }
        }
    }

    private func localized(_ key: String) -> String {
        let code = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: code, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
#Preview(traits: .sizeThatFitsLayout) {
    let vm = AuthViewModel(api: MockAuthNetworking())
    vm.isAuthenticated = true
    let lesson = Lesson(
        id: 1,
        lessonNumber: 2,
        time: "10:50 — 12:25",
        subject: LocalizedField(ru: "ООП", en: "OOP"),
        type: LocalizedField(ru: "Лекция", en: "Lecture"),
        teacher: LocalizedField(ru: "Иванов И. И.", en: "Ivanov I.I."),
        classroom: "Л-550",
        groups: [
            LocalizedField(ru: "ИБ-201", en: "IB-201"),
            LocalizedField(ru: "ИБ-202", en: "IB-202")
        ],
        isVirtual: true
    )
    return TeacherLessonRow(lesson: lesson)
        .environmentObject(vm)
        .padding()
}
