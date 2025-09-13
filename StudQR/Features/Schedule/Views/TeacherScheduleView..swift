//
//  TeacherScheduleView..swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct TeacherScheduleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"
    @StateObject private var vm = ScheduleViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.appBackground.ignoresSafeArea()
                    VStack {
                        DateScrollView(selectedDate: $vm.selectedDate,
                                       currentWeekStart: $vm.currentWeekStart)

                        let lessons = vm.daySchedule[vm.selectedDate] ?? []
                        if vm.isLoading {
                            VStack {
                                ProgressView().scaleEffect(1.5).padding()
                                Text(localized("loading"))
                                    .font(.headline)
                                    .foregroundColor(.secondaryText)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if lessons.isEmpty {
                            VStack {
                                Text(localized("no_classes"))
                                    .font(.largeTitle).fontWeight(.bold)
                                    .foregroundColor(.secondaryText)
                                Text("😃").font(.system(size: 80))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(lessons) { lesson in
                                TeacherLessonRow(lesson: lesson)
                                    .listRowBackground(Color.appBackground)
                            }
                            .listStyle(.plain)
                            .background(Color.appBackground)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .onAppear { vm.loadAround(date: vm.selectedDate, using: authViewModel, role: .teacher) }
            .onChange(of: vm.selectedDate) { _, newValue in
                if authViewModel.isAuthenticated {
                    vm.loadAround(date: newValue, using: authViewModel, role: .teacher)
                }
            }
        }
    }

    private func localized(_ key: String) -> String {
        let lang = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: lang, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    let auth = AuthViewModel(api: MockAuthNetworking())
    auth.token = "preview-token"
    auth.isAuthenticated = true
    return TeacherScheduleView()
        .environmentObject(auth)
        .environmentObject(ThemeManager())
}
