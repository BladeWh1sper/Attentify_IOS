//
//  ScheduleView.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import SwiftUI

struct DateScrollView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    @Binding private var currentWeekStart: Date
    @State private var dragOffset: CGFloat = 0
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    private let maxWeeks = 2

    init(selectedDate: Binding<Date>, currentWeekStart: Binding<Date>) {
        self._selectedDate = selectedDate
        self._currentWeekStart = currentWeekStart
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            HStack(spacing: 0) {
                weekView(for: calendar.date(byAdding: .day, value: -7, to: currentWeekStart)!)
                weekView(for: currentWeekStart)
                weekView(for: calendar.date(byAdding: .day, value: 7, to: currentWeekStart)!)
            }
            .frame(width: width * 3, alignment: .leading)
            .offset(x: dragOffset - width)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        let width = UIScreen.main.bounds.width

                        var newWeekStart = currentWeekStart
                        if value.translation.width < -threshold {
                            newWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) ?? currentWeekStart
                        } else if value.translation.width > threshold {
                            newWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
                        }

                        let diff = calendar.dateComponents([.weekOfYear], from: DateScrollView.startOfWeek(for: Date()), to: DateScrollView.startOfWeek(for: newWeekStart)).weekOfYear ?? 0

                        if abs(diff) <= maxWeeks {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dragOffset = value.translation.width < -threshold ? -width : (value.translation.width > threshold ? width : 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                currentWeekStart = newWeekStart
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
        .frame(height: 90)
    }

    func weekView(for weekStart: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                ForEach(getWeekDates(for: weekStart), id: \.self) { date in
                    let isToday = calendar.isDateInToday(date)
                    let isSelected = calendar.isDate(selectedDate, inSameDayAs: date)
                    VStack(spacing: 2) {
                        Text(formatDate(date))
                        Text(formatWeekday(date))
                    }
                    .frame(maxWidth: .infinity, minHeight: 30)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primaryText : .secondaryText)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(isSelected ? Color.cardBackground : Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isToday ? Color.red : (isSelected ? .primaryText : .clear), lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            Text(formatMonth(selectedDate))
                .font(.footnote)
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 8)
        }
        .padding(.horizontal, 8)
    }

    func getWeekDates(for weekStart: Date) -> [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }

    func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage == "en" ? "en_US" : "ru_RU")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage == "en" ? "en_US" : "ru_RU")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date).capitalized
    }

    static func startOfWeek(for date: Date) -> Date {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }
}


struct ScheduleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    @State private var selectedDate = Date()
    @State private var weekSchedule: [String: [Lesson]] = [:]
    @State private var currentWeekStart = DateScrollView.startOfWeek(for: Date())

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.appBackground
                        .ignoresSafeArea()

                    VStack {
                        DateScrollView(selectedDate: $selectedDate, currentWeekStart: $currentWeekStart)

                        let lessons = weekSchedule[getDayName(from: selectedDate)] ?? []

                        if lessons.isEmpty {
                            VStack {
                                Text(localized("no_classes"))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondaryText)

                                Text("😃")
                                    .font(.system(size: 80))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(lessons) { lesson in
                                LessonRow(lesson: lesson)
                                    .listRowBackground(Color.appBackground)
                            }
                            .listStyle(.plain)
                            .background(Color.appBackground)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            if value.translation.width < -threshold {
                                withAnimation {
                                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                                }
                                let newWeekStart = DateScrollView.startOfWeek(for: selectedDate)
                                if !Calendar.current.isDate(newWeekStart, inSameDayAs: currentWeekStart) {
                                    withAnimation {
                                        currentWeekStart = newWeekStart
                                    }
                                }
                            } else if value.translation.width > threshold {
                                withAnimation {
                                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                                }
                                let newWeekStart = DateScrollView.startOfWeek(for: selectedDate)
                                if !Calendar.current.isDate(newWeekStart, inSameDayAs: currentWeekStart) {
                                    withAnimation {
                                        currentWeekStart = newWeekStart
                                    }
                                }
                            }
                        }
                )
            }
            .onAppear {
                loadScheduleFromAPI(for: selectedDate)
            }
            .onChange(of: selectedDate) {
                if authViewModel.isAuthenticated {
                    loadScheduleFromAPI(for: selectedDate)
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

    func loadScheduleFromAPI(for date: Date) {
        let isUpper = isCurrentWeekUpper(for: date)
        let type = isUpper ? "upper" : "bottom"

        authViewModel.fetchSchedule(weekType: type)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let schedule = authViewModel.schedule {
                self.weekSchedule = schedule.days
            }
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
    ScheduleView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager())
}
