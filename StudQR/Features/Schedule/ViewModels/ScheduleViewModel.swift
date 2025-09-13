//
//  ScheduleViewModel.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation
import Combine

final class ScheduleViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var daySchedule: [Date: [Lesson]] = [:]
    @Published var currentWeekStart: Date = DateScrollView.startOfWeek(for: Date())
    @Published var isLoading: Bool = false

    /// Загружает расписание для `date-1 ... date ... date+1`, кеширует по дням.
    func loadAround(date: Date, using auth: AuthViewModel, role: ScheduleRole = .student) {
        guard auth.isAuthenticated else { return }
        isLoading = true
        let datesToLoad = (-1...1).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: date) }

        let group = DispatchGroup()
        for target in datesToLoad {
            if daySchedule[target] != nil { continue }
            group.enter()
            auth.fetchSchedule(for: target, role: role) { [weak self] lessons in
                DispatchQueue.main.async {
                    self?.daySchedule[target] = lessons
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in self?.isLoading = false }
    }
}
