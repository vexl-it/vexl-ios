//
//  SliderView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import UIKit
import SwiftUI

struct SliderView: UIViewRepresentable {

    final class Coordinator: NSObject {

        var value: Binding<Double>

        init(value: Binding<Double>) {
            self.value = value
        }

        @objc
        func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
    }

    var thumbColor: UIColor = .white
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?

    @Binding var value: Double

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.value = Float(value)
        slider.setThumbImage(R.image.offer.sliderThumb(), for: .normal)
        slider.setThumbImage(R.image.offer.sliderThumb(), for: .highlighted)

        slider.addTarget(context.coordinator,
                         action: #selector(Coordinator.valueChanged(_:)),
                         for: .valueChanged)

        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(self.value)
    }

    func makeCoordinator() -> SliderView.Coordinator {
        Coordinator(value: $value)
    }
}
