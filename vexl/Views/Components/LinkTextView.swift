//
//  LinkTextView.swift
//  vexl
//
//  Created by Diego Espinoza on 17/02/22.
//

import SwiftUI
import UIKit

struct LinkTextView: View {
    var text: String
    var links: [String: String]

    @State private var height: CGFloat = .zero

    private(set) var font: UIFont = Appearance.TextStyle.paragraph.font
    private(set) var linkFont: UIFont = Appearance.TextStyle.paragraph.font
    private(set) var textColor: UIColor = .white
    private(set) var linkColor: UIColor = .systemBlue
    private(set) var textAlignment: NSTextAlignment = .left

    var body: some View {
        InternalTextView(text: text,
                         links: links,
                         height: $height,
                         font: font,
                         linkFont: linkFont,
                         textColor: textColor,
                         linkColor: linkColor,
                         textAlignment: textAlignment)
            .frame(height: height)
    }

    struct InternalTextView: UIViewRepresentable {
        var text: String
        var links: [String: String]
        @Binding var height: CGFloat

        private(set) var font: UIFont
        private(set) var linkFont: UIFont
        private(set) var textColor: UIColor
        private(set) var linkColor: UIColor
        private(set) var textAlignment: NSTextAlignment

        func makeUIView(context: Context) -> UITextView {
            UITextView().tap {
                $0.backgroundColor = .clear
                $0.textAlignment = textAlignment
                $0.isScrollEnabled = false
                $0.isEditable = false
                $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                $0.textContainer.lineFragmentPadding = 0
                $0.textContainerInset = .zero
            }
        }

        func updateUIView(_ textView: UITextView, context: Context) {
            textView.tap {
                $0.textColor = textColor
                $0.font = font
                $0.textAlignment = textAlignment
                $0.linkTextAttributes = [
                    NSAttributedString.Key.underlineColor: textColor,
                    NSAttributedString.Key.foregroundColor: UIColor.white
                ]

                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = textAlignment

                let attributedText = NSMutableAttributedString(attributedString: text.configureAttributedText())
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor: textColor,
                                              NSAttributedString.Key.font: font,
                                              NSAttributedString.Key.paragraphStyle: paragraphStyle],
                                             range: NSRange(location: 0, length: attributedText.string.count))
                for (textToFind, linkURL) in links {
                    attributedText.setAsLink(textToFind: textToFind,
                                             linkURL: linkURL,
                                             linkColor: linkColor,
                                             linkFont: linkFont)
                }
                $0.attributedText = attributedText
            }

            InternalTextView.recalculateHeight(view: textView, result: $height)
        }

        fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
            let newSize = view.sizeThatFits(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude))

            guard result.wrappedValue != newSize.height else { return }
            DispatchQueue.main.async { // call in next render cycle
                result.wrappedValue = newSize.height
            }
        }
    }
}
