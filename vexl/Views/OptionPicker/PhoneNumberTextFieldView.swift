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

    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
        DispatchQueue.main.async {
            guard let text = uiView.text else { return }
            self.text = text
        }
    }

    func makeUIView(context: Context) -> PhoneNumberTextField {
        let phoneNumberTextField = PhoneNumberTextField()
        phoneNumberTextField.placeholder = placeholder
        return phoneNumberTextField
    }
}
