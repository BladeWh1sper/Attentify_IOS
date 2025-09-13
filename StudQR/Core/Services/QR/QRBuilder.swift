//
//  QRBuilder.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

func makeEncryptedQRJSON(sessionKey: String, scheduleId: Int, teacherId: Int) throws -> String {
    let payload: [String: Any] = [
        "schedule_id": scheduleId,
        "timestamp": Int(Date().timeIntervalSince1970)
    ]

    let encrypted = try encryptPayload(sessionKey: sessionKey, payload: payload)
    let root = TeacherQRRoot(teacher_id: teacherId, data: encrypted)

    let encoder = JSONEncoder()
    encoder.outputFormatting = []
    let data = try encoder.encode(root)
    return String(data: data, encoding: .utf8)!
}
