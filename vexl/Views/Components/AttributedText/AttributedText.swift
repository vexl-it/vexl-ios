//
//  AttributedText.swift
//  vexl
//
//  Created by Diego Espinoza on 5/08/22.
//

import SwiftUI

struct AttributedText: View {

    var attributedText: NSAttributedString
    var color: UIColor?
    @State private var height: CGFloat = .zero

    var body: some View {
        InternalTextView(attributedText: attributedText, color: color, dynamicHeight: $height)
            .frame(height: height)
    }

    private struct InternalTextView: UIViewRepresentable {

        var attributedText: NSAttributedString
        var color: UIColor?
        @Binding var dynamicHeight: CGFloat

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .vertical)

            if let color {
                label.textColor = color
            }

            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            if attributedText != uiView.attributedText {
                uiView.attributedText = attributedText
            }

            let height = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            if dynamicHeight != height {
                DispatchQueue.main.async {
                    dynamicHeight = height
                }
            }
        }
    }
}
