//
//  AuthViewModel.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation
import SwiftUI

final class AuthViewModel: ObservableObject {
    @AppStorage("authToken") private var savedToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"

    @Published var isAuthenticated = false
    @Published var token: String?
    @Published var profile: ProfileResponse?
    @Published var schedule: Schedule?

    private let baseURL = Constants.baseURL

    // ⬇️ Внедряем зависимость сети
    private let api: AuthNetworking

    // ⬇️ Дефолт — реальная сеть; в превью подменим
    init(api: AuthNetworking = RealAuthNetworking()) {
        self.api = api
        if !savedToken.isEmpty {
            token = savedToken
            isAuthenticated = true
            fetchProfile()
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        api.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self.token = token
                    self.savedToken = token
                    self.isAuthenticated = true
                    self.fetchProfile()
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }

    func fetchProfile() {
        guard let token = token else { return }
        api.fetchProfile(token: token) { result in
            DispatchQueue.main.async {
                if case let .success(profile) = result {
                    self.profile = profile
                }
            }
        }
    }

    func logout() {
        token = nil
        savedToken = ""
        profile = nil
        isAuthenticated = false
    }

    func fetchSchedule(for date: Date, completion: @escaping ([Lesson]) -> Void) {
        guard let token = token else { completion([]); return }
        api.fetchSchedule(token: token, date: date, completion: completion)
    }

    func confirmAttendance(with code: String, completion: @escaping (AttendanceStatus) -> Void) {
        guard let token = token else { completion(.failure); return }
        api.confirmAttendance(token: token, code: code, completion: completion)
    }
}
