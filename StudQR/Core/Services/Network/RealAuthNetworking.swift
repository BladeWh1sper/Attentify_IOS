//
//  RealAuthNetworking.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

struct RealAuthNetworking: AuthNetworking {
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        AuthAPIService.login(email: email, password: password, completion: completion)
    }
    func fetchProfile(token: String, completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        AuthAPIService.fetchProfile(token: token, completion: completion)
    }
    func fetchSchedule(token: String, date: Date, completion: @escaping ([Lesson]) -> Void) {
        AuthAPIService.fetchSchedule(token: token, date: date, completion: completion)
    }
    func confirmAttendance(token: String, code: String, completion: @escaping (AttendanceStatus) -> Void) {
        AuthAPIService.confirmAttendance(token: token, code: code, completion: completion)
    }
}
