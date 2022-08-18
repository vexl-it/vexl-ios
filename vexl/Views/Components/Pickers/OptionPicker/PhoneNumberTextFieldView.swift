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
    let regionCode: String
    let phoneNumber: String
    @Binding var text: String
    @Binding var isFocus: Bool

    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
        if isFocus && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFocus && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeUIView(context: Context) -> PhoneNumberTextField {
        let phoneNumberTextField = VexlPhoneNumberTextField(regionCode: regionCode, phoneNumber: phoneNumber)
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
            currentRegionCode
        }
        set { }
    }

    private var currentPhoneNumber = ""
    private var currentRegionCode = ""

    init(regionCode: String, phoneNumber: String) {
        self.currentPhoneNumber = phoneNumber
        self.currentRegionCode = regionCode
        super.init(frame: .zero)
        setPhoneNumber()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setPhoneNumber()
    }

    private func setPhoneNumber() {
        var calculatedText = ""

        if let countryCode = Formatters.phoneNumberFormatter.countryCode(for: self.currentRegionCode), !currentRegionCode.isEmpty {
            calculatedText = "+\(countryCode) "
        }

        if !currentPhoneNumber.isEmpty {
            calculatedText += "\(currentPhoneNumber)"
        }

        self.text = calculatedText
    }
}
