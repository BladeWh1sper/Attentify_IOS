//
//  SessionQRScreen.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import SwiftUI

struct SessionQRScreen: View {
    let sessionKey: String
    let scheduleId: Int
    let teacherId: Int

    @State private var qrValue: String?
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            if let value = qrValue {
                QRCodeView(value: value)
            } else {
                ProgressView("Готовим QR…")
            }
            Text("QR обновляется каждые 5 сек, TTL 30 сек")
                .font(.footnote)
                .foregroundColor(.secondaryText)
        }
        .padding()
        .onAppear {
            regenerate()
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                regenerate()
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    private func regenerate() {
        qrValue = try? makeEncryptedQRJSON(
            sessionKey: sessionKey,
            scheduleId: scheduleId,
            teacherId: teacherId
        )
    }
}
