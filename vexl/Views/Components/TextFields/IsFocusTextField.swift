//
//  IsFocusTextField.swift
//  vexl
//
//  Created by Vendula Švastalová on 15.04.2022.
//

import Foundation
import SwiftUI

/// Custom wrapper around UITextField
///
/// This view had to be created because there is currently
/// no option to control SecureField's focus as it has
/// different interface than TextField and this option is missing.
struct IsFocusTextField: UIViewRepresentable {
    // MARK: - Internal properties

    /// Text of the text field
    @Binding var text: String

    // MARK: - Private properties

    /// Placeholder of the text field
    private let placeholder: String
    /// Indicates whether the text field has focus / is first responder
    private var isFocused: Binding<Bool> {
        hasExternalEditing ? $isFocusedExternal : $isFocusedInternal
    }
    @State private var isFocusedInternal: Bool = false
    @Binding private var isFocusedExternal: Bool
    private let hasExternalEditing: Bool

    init(
        placeholder: String,
        text: Binding<String>,
        isFocused: Binding<Bool>? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        if let isFocused = isFocused {
            _isFocusedExternal = isFocused
            hasExternalEditing = true
        } else {
            _isFocusedExternal = .constant(false)
            hasExternalEditing = false
        }
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        setupView(textField, context: context)

        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if isFocused.wrappedValue {
            textField.becomeFirstResponder()
        }

        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textFieldDidChange), for: .editingChanged)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        setupView(uiView, context: context)

        uiView.text = text
        uiView.isEnabled = context.environment.isEnabled

        if isFocused.wrappedValue {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> CustomTextFieldCoordinator {
        CustomTextFieldCoordinator(
            self,
            isEditing: isFocused
        )
    }

    private func setupView(_ textField: UITextField, context: Context) {
        textField.attributedPlaceholder = .init(
            string: placeholder
        )
        textField.textColor = R.color.yellow100()
        textField.autocorrectionType = .no
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: R.color.gray4() ?? .gray]
        )
    }
}

// MARK: - Coordinator

final class CustomTextFieldCoordinator: NSObject {
    fileprivate let parent: IsFocusTextField

    @Binding var isEditing: Bool

    var shouldReturn: () -> Void = { }

    init(
        _ parent: IsFocusTextField,
        isEditing: Binding<Bool>
    ) {
        self.parent = parent
        self._isEditing = isEditing
    }
}

extension CustomTextFieldCoordinator: UITextFieldDelegate {
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        parent.text = textField.text ?? ""
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.isEditing {
                self.isEditing = true
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isEditing {
                self.isEditing = false
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isEditing = false
        textField.resignFirstResponder()
        shouldReturn()
        return true
    }
}
