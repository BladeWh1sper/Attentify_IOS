//
//  MainPageView.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    @State private var todayLessons: [Lesson] = []
    @State private var fetchedWeekType: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Text(localized("today_title"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    if todayLessons.isEmpty {
                        VStack {
                            Text(localized("no_classes_today"))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.secondaryText)

                            Text("😃")
                                .font(.system(size: 80))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(todayLessons) { lesson in
                            LessonRow(lesson: lesson)
                                .listRowBackground(Color.appBackground)
                        }
                        .listStyle(.plain)
                        .background(Color.appBackground)
                    }
                }
            }
            .onAppear {
                if authViewModel.isAuthenticated {
                    loadTodaySchedule()
                }
            }
        }
    }

    func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    func loadTodaySchedule() {
        let today = Date()
        
        authViewModel.fetchSchedule(for: today) { lessons in
            DispatchQueue.main.async {
                self.todayLessons = lessons
            }
        }
    }
}

#Preview {
    MainPageView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager())
}
