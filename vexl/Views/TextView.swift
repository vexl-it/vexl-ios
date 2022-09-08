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
    var characterLimit: Int

    typealias UIViewType = UITextView

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let view = UIViewType()
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

    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, characterLimit: characterLimit)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        let parent: TextView
        let characterLimit: Int

        init(_ parent: TextView, characterLimit: Int) {
            self.parent = parent
            self.characterLimit = characterLimit
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if textView.text.count + (text.count - range.length) <= characterLimit {
                notifyParent(textView,
                             shouldChangeTextIn: range,
                             replacementText: text)
                return false
            } else {
                return textView.text.count + (text.count - range.length) <= characterLimit
            }
        }

        func notifyParent(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
            if let value = textView.text as NSString? {
                let proposedValue = value.replacingCharacters(in: range, with: text)
                parent.text = proposedValue as String
            }
        }
    }
}
