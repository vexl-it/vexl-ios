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
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        let parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            notifyParent(textView,
                         shouldChangeTextIn: range,
                         replacementText: text)
            return false
        }

        func notifyParent(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
            if let value = textView.text as NSString? {
                let proposedValue = value.replacingCharacters(in: range, with: text)
                parent.text = proposedValue as String
            }
        }
    }
}
