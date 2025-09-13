//
//  CameraPermissionManager.swift
//  Attentify
//
//  Created by Andrew Belik on 9/13/25.
//

import AVFoundation

enum CameraAuthStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
}

struct CameraPermissionManager {
    static func status() -> CameraAuthStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:   return .authorized
        case .denied:       return .denied
        case .restricted:   return .restricted
        case .notDetermined:return .notDetermined
        @unknown default:   return .restricted
        }
    }

    static func request(completion: @escaping (CameraAuthStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted ? .authorized : .denied)
            }
        }
    }
}
