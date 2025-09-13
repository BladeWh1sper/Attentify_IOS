//
//  ScheduleView.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    @StateObject private var vm = ScheduleViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.appBackground.ignoresSafeArea()
                    VStack {
                        DateScrollView(selectedDate: $vm.selectedDate, currentWeekStart: $vm.currentWeekStart)

                        let lessons = vm.daySchedule[vm.selectedDate] ?? []
                        if vm.isLoading {
                            VStack {
                                ProgressView().scaleEffect(1.5).padding()
                                Text(localized("loading")).font(.headline).foregroundColor(.secondaryText)
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
                    DragGesture().onEnded { value in
                        let threshold: CGFloat = 50
                        let calendar = Calendar.current
                        if value.translation.width < -threshold {
                            let newDate = calendar.date(byAdding: .day, value: 1, to: vm.selectedDate) ?? vm.selectedDate
                            withAnimation { vm.selectedDate = newDate }
                            if let preload = calendar.date(byAdding: .day, value: 1, to: newDate) {
                                vm.loadAround(date: preload, using: authViewModel)
                            }
                            let newWeek = DateScrollView.startOfWeek(for: newDate)
                            if !calendar.isDate(newWeek, inSameDayAs: vm.currentWeekStart) {
                                withAnimation { vm.currentWeekStart = newWeek }
                            }
                        } else if value.translation.width > threshold {
                            let newDate = calendar.date(byAdding: .day, value: -1, to: vm.selectedDate) ?? vm.selectedDate
                            withAnimation { vm.selectedDate = newDate }
                            if let preload = calendar.date(byAdding: .day, value: -1, to: newDate) {
                                vm.loadAround(date: preload, using: authViewModel)
                            }
                            let newWeek = DateScrollView.startOfWeek(for: newDate)
                            if !calendar.isDate(newWeek, inSameDayAs: vm.currentWeekStart) {
                                withAnimation { vm.currentWeekStart = newWeek }
                            }
                        }
                    }
                )
            }
            .onAppear { vm.loadAround(date: vm.selectedDate, using: authViewModel) }
            .onChange(of: vm.selectedDate) { _, newValue in
                if authViewModel.isAuthenticated {
                    vm.loadAround(date: newValue, using: authViewModel)
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
    // Превью без реальной сети
    let auth = AuthViewModel(api: MockAuthNetworking())
    auth.token = "preview-token"
    auth.isAuthenticated = true

    return ScheduleView()
        .environmentObject(auth)
        .environmentObject(ThemeManager())
}
