//
//  CameraPreviewViewDelegate.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import AVFoundation

final class CameraPreviewViewDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    var scanInterval: Double = 1.0
    var lastTime = Date(timeIntervalSince1970: 0)
    var onResult: ((String) -> Void)?

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
            self.onResult?(stringValue)
        }
    }
}
