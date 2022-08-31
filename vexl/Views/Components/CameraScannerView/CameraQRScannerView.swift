//
//  CameraQRScannerView.swift
//  vexl
//
//  Created by Diego Espinoza on 29/08/22.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraQRScannerView: UIViewRepresentable {
    var viewModel: CameraPreviewViewModel

    func makeUIView(context: Context) -> CameraPreviewLayerView {
        let view = CameraPreviewLayerView(previewLayer: viewModel.cameraLayer)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewLayerView, context: Context) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}
