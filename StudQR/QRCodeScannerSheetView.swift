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

        init(parent: QRCodeScannerSheetView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let stringValue = metadataObject.stringValue {
                DispatchQueue.main.async {
                    self.parent.scannedCode = stringValue
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    @Binding var scannedCode: String
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
