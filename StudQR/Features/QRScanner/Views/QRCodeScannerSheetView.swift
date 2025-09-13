//
//  QRCodeScannerSheetView.swift
//  StudQR
//
//  Created by Andrew Belik on 5/24/25.
//

import SwiftUI
import AVFoundation

struct QRCodeScannerSheetView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerSheetView
        init(parent: QRCodeScannerSheetView) { self.parent = parent }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            if let m = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let value = m.stringValue {
                DispatchQueue.main.async {
                    self.parent.scannedCode = value
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    @Binding var scannedCode: String
    @Environment(\.presentationMode) var presentationMode

    // держим сессию, чтобы не умерла раньше времени
    private let session = AVCaptureSession()

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .black

        // Вход
        guard let device = AVCaptureDevice.default(for: .video) else { return vc }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            // не удалось получить доступ к камере
            return vc
        }

        // Выход (метаданные)
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        // Превью
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = vc.view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        vc.view.layer.addSublayer(preview)

        // Стартуем асинхронно
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }

        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    // Останавливаем камеру, когда вью уходит
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        // Пытаемся достать слой и остановить сессию
        (uiViewController.view.layer.sublayers?.first { $0 is AVCaptureVideoPreviewLayer } as? AVCaptureVideoPreviewLayer)?
            .session?.stopRunning()
    }
}
