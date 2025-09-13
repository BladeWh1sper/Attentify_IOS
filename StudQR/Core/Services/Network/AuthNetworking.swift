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
    
    // Новый вариант с ролью (teacher/student)
    func fetchSchedule(token: String, date: Date, role: ScheduleRole, completion: @escaping ([Lesson]) -> Void)

    // Оставляем старый для совместимости (дефолт: student)
    func fetchSchedule(token: String, date: Date, completion: @escaping ([Lesson]) -> Void)
    
    func confirmAttendance(token: String, code: String, completion: @escaping (AttendanceStatus) -> Void)
    
    func createSession(token: String, completion: @escaping (Result<String, Error>) -> Void)
}
