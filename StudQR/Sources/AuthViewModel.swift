//
//  AuthViewModel.swift
//  StudQR
//
//  Created by Andrew Belik on 5/19/25.
//

import SwiftUI
import Foundation

enum AttendanceStatus {
    case success
    case alreadyMarked
    case failure
}


struct ProfileResponse: Codable {
    let id: Int
    let email: String
    let is_superuser: Bool
    let profile: ProfileInfo
    let role: Role
    let groups: [Group]
}

struct ProfileInfo: Codable {
    let id: Int
    let first_name: LocalizedField
    let last_name: LocalizedField
    let patronymic: LocalizedField
    let phone: String? // <-- nullable
}

struct Role: Codable {
    let id: Int
    let name: LocalizedField
    let description: LocalizedFieldOptional // <-- nullable fields
}

struct Group: Codable {
    let id: Int
    let name: LocalizedField
    let description: LocalizedFieldOptional
}

struct LocalizedField: Codable {
    let ru: String
    let en: String
}

struct LocalizedFieldOptional: Codable {
    let ru: String?
    let en: String?
}



struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
}


class AuthViewModel: ObservableObject {
    @AppStorage("authToken") private var savedToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"

    @Published var isAuthenticated = false
    @Published var token: String?
    @Published var profile: ProfileResponse?
    @Published var schedule: Schedule?
    private let baseURL = Constants.baseURL
    
    init() {
        if !savedToken.isEmpty {
            token = savedToken
            isAuthenticated = true
            fetchProfile()
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Constants.baseURL + Constants.loginEndpoint) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "username=\(email)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Login error:", error)
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse else {
                print("No data or invalid response")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.token = result.access_token
                        self.savedToken = result.access_token
                        self.isAuthenticated = true
                        self.fetchProfile()
                        completion(true)
                    }
                } catch {
                    print("❌ Decoding error:", error)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

    func fetchProfile() {
        guard let token = token,
              let url = URL(string: Constants.baseURL + Constants.profileEndpoint) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Profile fetch error:", error)
                return
            }

            guard let data = data else {
                print("No data for profile")
                return
            }

            do {
                let result = try JSONDecoder().decode(ProfileResponse.self, from: data)
                DispatchQueue.main.async {
                    self.profile = result
                }
            } catch {
                print("❌ Profile decoding error:", error)
                if let html = String(data: data, encoding: .utf8) {
                    print("Returned HTML:", html)
                }
            }
        }.resume()
    }

    func logout() {
        token = nil
        savedToken = ""
        profile = nil
        isAuthenticated = false
    }
    
    func fetchSchedule(for date: Date, completion: @escaping ([Lesson]) -> Void) {
        guard let token = token else {
            completion([])
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let baseUrl = Constants.baseURL + Constants.scheduleEndpoint
        guard var components = URLComponents(string: baseUrl) else {
            print("❌ Invalid base URL")
            completion([])
            return
        }

        components.queryItems = [URLQueryItem(name: "target_date", value: dateString)]

        guard let url = components.url else {
            print("❌ Invalid composed URL")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("❌ No data:", error ?? "")
                completion([])
                return
            }

            do {
                let lessons = try JSONDecoder().decode([Lesson].self, from: data)
                completion(lessons)
            } catch {
                print("❌ Decoding error:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Returned:", raw)
                }
                completion([])
            }
        }.resume()
    }
}

extension AuthViewModel {
    func confirmAttendance(with code: String, completion: @escaping (AttendanceStatus) -> Void) {
        guard let token = token,
              let url = URL(string: Constants.baseURL + Constants.attendanceEndpoint) else {
            completion(.failure)
            return
        }

        guard let qrData = code.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: qrData) as? [String: Any],
              let teacherId = json["teacher_id"] as? Int,
              let data = json["data"] as? String else {
            print("❌ Invalid QR format")
            completion(.failure)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "teacher_id": teacherId,
            "data": data
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Attendance confirm error:", error)
                DispatchQueue.main.async {
                    completion(.failure)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure)
                }
                return
            }

            DispatchQueue.main.async {
                switch httpResponse.statusCode {
                case 201:
                    print("✅ Attendance confirmed (201)")
                    completion(.success)
                case 409:
                    print("⚠️ Already marked attendance (409)")
                    completion(.alreadyMarked)
                default:
                    print("❌ Attendance failed, code: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    completion(.failure)
                }
            }
        }.resume()
    }

    func localized(_ field: LocalizedField) -> String {
        selectedLanguage == "en" ? field.en : field.ru
    }

    func localized(_ field: LocalizedFieldOptional) -> String {
        if selectedLanguage == "en" {
            return field.en ?? ""
        } else {
            return field.ru ?? ""
        }
    }
}
