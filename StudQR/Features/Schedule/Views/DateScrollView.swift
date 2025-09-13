//
//  DateScrollView.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct DateScrollView: View {
    @Binding var selectedDate: Date
    @Binding private var currentWeekStart: Date
    @State private var dragOffset: CGFloat = 0
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    private let calendar = Calendar.current
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
                    .onChanged { dragOffset = $0.translation.width }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        let screenW = UIScreen.main.bounds.width

                        var newWeekStart = currentWeekStart
                        if value.translation.width < -threshold {
                            newWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) ?? currentWeekStart
                        } else if value.translation.width > threshold {
                            newWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
                        }

                        let diff = calendar.dateComponents([.weekOfYear],
                                                           from: DateScrollView.startOfWeek(for: Date()),
                                                           to: DateScrollView.startOfWeek(for: newWeekStart)).weekOfYear ?? 0

                        if abs(diff) <= maxWeeks {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dragOffset = value.translation.width < -threshold ? -screenW :
                                             (value.translation.width > threshold ? screenW : 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                currentWeekStart = newWeekStart
                                dragOffset = 0
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) { dragOffset = 0 }
                        }
                    }
            )
        }
        .frame(height: 90)
    }

    private func weekView(for weekStart: Date) -> some View {
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
                    .onTapGesture { selectedDate = date }
                }
            }
            Text(formatMonth(selectedDate))
                .font(.footnote)
                .foregroundColor(.secondaryText)
                .padding(.horizontal, 8)
        }
        .padding(.horizontal, 8)
    }

    private func getWeekDates(for weekStart: Date) -> [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd"
        return f.string(from: date)
    }

    private func formatWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: selectedLanguage == "en" ? "en_US" : "ru_RU")
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    private func formatMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: selectedLanguage == "en" ? "en_US" : "ru_RU")
        f.dateFormat = "LLLL"
        return f.string(from: date).capitalized
    }

    static func startOfWeek(for date: Date) -> Date {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone.current
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }
}
