//
//  TextView.swift
//  vexl
//
//  Created by Thành Đỗ Long on 24.08.2022.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    let textStyle: Appearance.TextStyle
    let textColor: UIColor
    var cursorColor: UIColor = R.color.yellow100() ?? .yellow
    var isFirstResponder: Bool = false
    var characterLimit: Int?

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let view = UITextView()
        view.text = text
        view.font = textStyle.font
        view.textColor = textColor
        view.tintColor = cursorColor
        view.delegate = context.coordinator
        view.backgroundColor = .clear

        if isFirstResponder {
            view.becomeFirstResponder()
        }

        return view
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        if text.isEmpty {
            uiView.text = ""
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text, characterLimit: characterLimit)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        let characterLimit: Int?

        init(_ textBinding: Binding<String>, characterLimit: Int?) {
            self._text = textBinding
            self.characterLimit = characterLimit
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let shouldChange = textShouldChange(textView: textView, shouldChangeTextIn: range, replacementText: text)
            if shouldChange, let value = textView.text as NSString? {
                let proposedValue = value.replacingCharacters(in: range, with: text)
                self.text = proposedValue
            }
            return shouldChange
        }

        private func textShouldChange(textView: UITextView,
                                      shouldChangeTextIn range: NSRange,
                                      replacementText text: String) -> Bool {
            if let characterLimit {
                return textView.text.count + (text.count - range.length) <= characterLimit
            }

            return true
        }
    }
}
