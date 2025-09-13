//
//  AuthResponseDTO.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
}
