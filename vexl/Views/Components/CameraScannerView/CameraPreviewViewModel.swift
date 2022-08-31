//
//  CameraPreviewViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 29/08/22.
//

import Foundation
import AVFoundation
import Combine

enum CameraPreviewError: LocalizedError {
    case failedSetup

    var errorDescription: String? {
        L.groupsEnterCameraError()
    }
}

final class CameraPreviewViewModel: NSObject {

    var onResult: PassthroughSubject<String, Never> = .init()
    var onError: PassthroughSubject<Void, CameraPreviewError> = .init()

    var cameraLayer: CALayer {
        guard let previewLayer = previewLayer else { return CALayer() }
        return previewLayer
    }

    private var scanInterval: Double = 1.0
    private var lastTime = Date(timeIntervalSince1970: 0)
    private var captureSession: AVCaptureSession?
    private lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        guard let captureSession = captureSession else { return nil }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()

    private func makeVideoDeviceInput(captureSession: AVCaptureSession) -> AVCaptureDeviceInput? {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return nil }

        let captureDeviceInput: AVCaptureDeviceInput?
        do { captureDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice) } catch { return nil }

        if let videoInput = captureDeviceInput, captureSession.canAddInput(videoInput) {
            return videoInput
        } else {
            return nil
        }
    }

    private func makeSessionMetadataOutput(captureSession: AVCaptureSession) -> AVCaptureMetadataOutput? {
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else { return nil }
        return metadataOutput
    }

    func createSession() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            onError.send(completion: .failure(.failedSetup))
            return
        }

        let session = AVCaptureSession()

        guard let sessionInput = makeVideoDeviceInput(captureSession: session) else {
            onError.send(completion: .failure(.failedSetup))
            return
        }
        session.addInput(sessionInput)

        guard let sessionOutput = makeSessionMetadataOutput(captureSession: session) else {
            onError.send(completion: .failure(.failedSetup))
            return
        }
        session.addOutput(sessionOutput)

        guard sessionOutput.availableMetadataObjectTypes.contains(.qr) else {
            onError.send(completion: .failure(.failedSetup))
            return
        }
        sessionOutput.metadataObjectTypes = [.qr]
        sessionOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

        captureSession = session
    }

    func startSession() {
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }

    func stopSession() {
        captureSession?.stopRunning()
    }
}

extension CameraPreviewViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            foundBarcode(stringValue)
        }
    }

    func foundBarcode(_ stringValue: String) {
        let now = Date()
        if now.timeIntervalSince(lastTime) >= scanInterval {
            lastTime = now
            self.onResult.send(stringValue)
        }
    }
}
