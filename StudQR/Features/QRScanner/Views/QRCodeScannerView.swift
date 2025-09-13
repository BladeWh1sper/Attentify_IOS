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
    @State private var cameraStatus: CameraAuthStatus = CameraPermissionManager.status()

    var body: some View {
        VStack(spacing: 20) {
            if let message = confirmationMessage {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
            }

            switch cameraStatus {
            case .authorized:
                Button(localized("scan_button")) { isShowingScanner = true }
                    .padding()
                    .sheet(isPresented: $isShowingScanner) {
                        QRCodeScannerSheetView(scannedCode: $scannedCode)
                            .onDisappear { handleScannedIfNeeded() }
                    }
                    .onAppear {
                        // Автооткрытие листа один раз, если нужно
                        if isShowingScanner == false { isShowingScanner = true }
                    }

            case .notDetermined:
                Button(localized("request_camera_permission")) {
                    CameraPermissionManager.request { status in
                        cameraStatus = status
                    }
                }

            case .denied, .restricted:
                VStack(spacing: 8) {
                    Text(localized("camera_denied"))
                        .foregroundColor(.secondaryText)
                    Button(localized("open_settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
    }

    private func handleScannedIfNeeded() {
        guard !scannedCode.isEmpty else { return }
        authViewModel.confirmAttendance(with: scannedCode) { status in
            switch status {
            case .success:       confirmationMessage = localized("scan_success")
            case .alreadyMarked: confirmationMessage = localized("scan_already")
            case .failure:       confirmationMessage = localized("scan_failure")
            }
        }
    }

    private func localized(_ key: String) -> String {
        let code = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: code, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    // Превью без камеры и сети
    let vm = AuthViewModel(api: MockAuthNetworking())
    vm.token = "preview-token"
    vm.isAuthenticated = true

    return VStack {
        // Экран сканер
        QRCodeScannerView()
            .environmentObject(vm)
            .environmentObject(ThemeManager())

        // Демонстрация результата без камеры:
        Divider().padding(.vertical, 8)
        Text("Preview note: camera not available. Using MockAuthNetworking.")
            .font(.footnote)
            .foregroundColor(.secondaryText)
    }
    .padding()
}
