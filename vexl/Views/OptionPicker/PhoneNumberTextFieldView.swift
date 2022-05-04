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
    }
    
    func makeUIView(context: Context) -> PhoneNumberTextField {
        let phoneNumberTextField = PhoneNumberTextField()
        phoneNumberTextField.addTarget(context.coordinator, action: #selector(Coordinator.onTextChange), for: .editingChanged)
        phoneNumberTextField.placeholder = placeholder
        return phoneNumberTextField
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PhoneNumberTextFieldView
        
        init(_ parent: PhoneNumberTextFieldView) {
            self.parent = parent
        }

        @objc
        func onTextChange(textField: UITextField) {
            parent.text = textField.text!
        }
    }
}
