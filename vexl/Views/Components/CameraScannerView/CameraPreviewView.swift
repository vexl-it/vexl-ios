//
//  CameraScannerView.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import UIKit
import AVFoundation

final class CameraPreviewView: UIView {

    var previewLayer: AVCaptureVideoPreviewLayer?
    var session = AVCaptureSession()
    weak var delegate: CameraPreviewViewDelegate?

    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        self.session = session
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = self.bounds
    }
}
