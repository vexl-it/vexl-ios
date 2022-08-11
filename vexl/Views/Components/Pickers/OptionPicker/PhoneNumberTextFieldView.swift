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
    let font: UIFont
    @Binding var text: String

    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
    }

    func makeUIView(context: Context) -> PhoneNumberTextField {
        let phoneNumberTextField = VexlPhoneNumberTextField()
        phoneNumberTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        phoneNumberTextField.addTarget(context.coordinator, action: #selector(Coordinator.onTextChange), for: .editingChanged)
        phoneNumberTextField.placeholder = placeholder
        phoneNumberTextField.font = font
        phoneNumberTextField.withFlag = true
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

private class VexlPhoneNumberTextField: PhoneNumberTextField {
    override var defaultRegion: String {
        get {
            Locale.current.regionCode ?? ""
        }
        set { }
    }

    init() {
        super.init(frame: .zero)
        setInitialCountryCode()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setInitialCountryCode()
    }

    private func setInitialCountryCode() {
        if let countryCode = Formatters.phoneNumberFormatter.countryCode(for: defaultRegion) {
            text = "+\(countryCode)"
        }
    }
}
