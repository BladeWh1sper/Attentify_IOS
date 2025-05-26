//
//  QRCodeScannerView.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import SwiftUI

struct QRCodeScannerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    @State private var scannedCode = ""
    @State private var isShowingScanner = false
    @State private var confirmationMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            if let message = confirmationMessage {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
            }

            Button(localized("scan_button")) {
                isShowingScanner = true
            }
            .padding()
            .onAppear {
                isShowingScanner = true
            }
            .sheet(isPresented: $isShowingScanner) {
                QRCodeScannerSheetView(scannedCode: $scannedCode)
                    .onDisappear {
                        if !scannedCode.isEmpty {
                            authViewModel.confirmAttendance(with: scannedCode) { status in
                                switch status {
                                case .success:
                                    confirmationMessage = localized("scan_success")
                                case .alreadyMarked:
                                    confirmationMessage = localized("scan_already")
                                case .failure:
                                    confirmationMessage = localized("scan_failure")
                                }
                            }
                        }
                    }
            }
        }
        
    }

    func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    QRCodeScannerView()
        .environmentObject(AuthViewModel())
}
