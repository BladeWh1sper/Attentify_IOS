//
//  ProfileHeader.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct ProfileHeader: View {
    let initials: String
    let tint: Color

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 100, height: 100)
                Text(initials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(tint)
            }
            Spacer()
        }
    }
}
