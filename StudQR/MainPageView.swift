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
//            .navigationTitle(localized("today_title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .foregroundColor(.accentColor)
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
        let today = getDayName(from: Date())
        let isUpper = isCurrentWeekUpper(for: Date())
        let weekType = isUpper ? "upper" : "bottom"

        if fetchedWeekType == weekType, let cached = authViewModel.schedule?.days[today] {
            self.todayLessons = cached
            return
        }

        fetchedWeekType = weekType
        authViewModel.fetchSchedule(weekType: weekType)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.todayLessons = authViewModel.schedule?.days[today] ?? []
        }
    }

    func getDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    func isCurrentWeekUpper(for date: Date) -> Bool {
        let calendar = Calendar.current
        let startDate = DateComponents(calendar: calendar, year: 2024, month: 2, day: 10).date!
        let weekNumber = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
        return weekNumber % 2 == 0
    }
}

#Preview {
    MainPageView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager())
}
