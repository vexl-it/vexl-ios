//
//  AttributedText.swift
//  vexl
//
//  Created by Diego Espinoza on 5/08/22.
//

import SwiftUI

struct AttributedText: View {

    var attributedText: NSAttributedString
    @State private var height: CGFloat = .zero

    var body: some View {
        InternalTextView(attributedText: attributedText, dynamicHeight: $height)
            .frame(height: height)
    }

    struct InternalTextView: UIViewRepresentable {

        var attributedText: NSAttributedString
        @Binding var dynamicHeight: CGFloat

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            uiView.attributedText = attributedText
            DispatchQueue.main.async {
                dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            }
        }
    }
}
