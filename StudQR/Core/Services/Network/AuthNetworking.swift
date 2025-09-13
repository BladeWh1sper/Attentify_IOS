//
//  AuthNetworking.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

protocol AuthNetworking {
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void)
    func fetchProfile(token: String, completion: @escaping (Result<ProfileResponse, Error>) -> Void)
    func fetchSchedule(token: String, date: Date, completion: @escaping ([Lesson]) -> Void)
    func confirmAttendance(token: String, code: String, completion: @escaping (AttendanceStatus) -> Void)
}
