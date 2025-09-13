//
//  ProfileDTO.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

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
    let phone: String?
}

struct Role: Codable {
    let id: Int
    let name: LocalizedField
    let description: LocalizedFieldOptional
}

struct Group: Codable {
    let id: Int
    let name: LocalizedField
    let description: LocalizedFieldOptional
}
