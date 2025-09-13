//
//  AuthAPIService.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

enum AuthAPIService {
    static func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: Constants.baseURL + Constants.loginEndpoint) else {
            completion(.failure(NSError()))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "username=\(email)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                completion(.failure(NSError())); return
            }
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                completion(.success(result.access_token))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    static func fetchProfile(token: String, completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        guard let url = URL(string: Constants.baseURL + Constants.profileEndpoint) else {
            completion(.failure(NSError()))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                completion(.failure(NSError())); return
            }
            do {
                let result = try JSONDecoder().decode(ProfileResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    static func fetchSchedule(token: String, date: Date, completion: @escaping ([Lesson]) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let baseUrl = Constants.baseURL + Constants.scheduleEndpoint
        guard var components = URLComponents(string: baseUrl) else {
            completion([]); return
        }
        components.queryItems = [URLQueryItem(name: "target_date", value: dateString)]
        guard let url = components.url else {
            completion([]); return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion([]); return
            }
            do {
                // ВАЖНО: декодируем DTO и маппим в доменную модель
                let dtoList = try JSONDecoder().decode([LessonDTO].self, from: data)
                let lessons = dtoList.map { $0.toDomain() }
                completion(lessons)
            } catch {
                completion([])
            }
        }.resume()
    }

    static func confirmAttendance(token: String, code: String, completion: @escaping (AttendanceStatus) -> Void) {
        guard let qrData = code.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: qrData) as? [String: Any],
              let teacherId = json["teacher_id"] as? Int,
              let data = json["data"] as? String,
              let url = URL(string: Constants.baseURL + Constants.attendanceEndpoint)
        else {
            completion(.failure); return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["teacher_id": teacherId, "data": data]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure) }
                return
            }
            DispatchQueue.main.async {
                switch httpResponse.statusCode {
                case 201: completion(.success)
                case 409: completion(.alreadyMarked)
                default:  completion(.failure)
                }
            }
        }.resume()
    }
}
