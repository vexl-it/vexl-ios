//
//  CameraPreviewView2.swift
//  vexl
//
//  Created by Diego Espinoza on 29/08/22.
//

import UIKit
import AVFoundation

final class CameraPreviewLayerView: UIView {

    var previewLayer: CALayer

    init(previewLayer: CALayer) {
        self.previewLayer = previewLayer
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.addSublayer(previewLayer)
        previewLayer.frame = self.bounds
    }
}
