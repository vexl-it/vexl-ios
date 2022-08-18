//
//  CameraScannerView.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraScannerView: UIViewRepresentable {

    var supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.qr]

    private let session = AVCaptureSession()
    private let delegate = CameraPreviewViewDelegate()
    private let metadataOutput = AVCaptureMetadataOutput()

    func interval(delay: Double) -> CameraScannerView {
        delegate.scanInterval = delay
        return self
    }

    func onScan(_ onScan: @escaping (String) -> Void) -> CameraScannerView {
        delegate.onResult = onScan
        return self
    }

    func setupCamera(_ uiView: CameraPreviewView) {
        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video) {
            if let input = try? AVCaptureDeviceInput(device: backCamera) {
                session.sessionPreset = .photo

                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(metadataOutput) {
                    session.addOutput(metadataOutput)

                    metadataOutput.metadataObjectTypes = supportedBarcodeTypes
                    metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                }

                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                uiView.backgroundColor = UIColor.gray
                previewLayer.videoGravity = .resizeAspectFill
                uiView.layer.addSublayer(previewLayer)
                uiView.previewLayer = previewLayer
                session.startRunning()
            }
        }
    }

    func makeUIView(context: UIViewRepresentableContext<CameraScannerView>) -> CameraPreviewView {
        let cameraView = CameraPreviewView(session: session)
        setupCamera(cameraView)
        return cameraView
    }

    static func dismantleUIView(_ uiView: CameraPreviewView, coordinator: ()) {
        uiView.session.stopRunning()
    }

    func updateUIView(_ uiView: CameraPreviewView, context: UIViewRepresentableContext<CameraScannerView>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}
