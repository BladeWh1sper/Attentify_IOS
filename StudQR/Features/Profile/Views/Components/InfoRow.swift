//
//  InfoRow.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title + ":")
                .foregroundColor(.secondaryText)
            Text(value)
                .foregroundColor(.primaryText)
            Spacer()
        }
        .font(.body)
    }
}
