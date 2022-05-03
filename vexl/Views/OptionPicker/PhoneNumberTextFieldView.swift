//
//  PhoneNumberTextFieldView.swift
//  vexl
//
//  Created by Diego Espinoza on 3/05/22.
//

import UIKit
import SwiftUI
import PhoneNumberKit

struct PhoneNumberTextFieldView: UIViewRepresentable {

    let placeholder: String
    @Binding var text: String

    func updateUIView(_ uiView: CallbackPhoneNumberTextField, context: Context) {
        uiView.text = context.coordinator.text
    }

    func makeUIView(context: Context) -> CallbackPhoneNumberTextField {
        let phoneNumberTextField = CallbackPhoneNumberTextField()
        phoneNumberTextField.placeholder = placeholder
        return phoneNumberTextField
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: self.$text)
    }

    class Coordinator: NSObject {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
            super.init()
        }
    }

    class CallbackPhoneNumberTextField: PhoneNumberTextField {
        override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
            print(text)
            return super.shouldChangeText(in: range, replacementText: text)
        }
    }
}
