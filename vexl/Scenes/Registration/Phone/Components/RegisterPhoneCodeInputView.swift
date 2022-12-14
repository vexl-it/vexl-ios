//
//  RegisterPhoneView+CodeInput.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Cleevio

struct RegisterPhoneCodeInputView: View {

    let phoneNumber: NSAttributedString
    let isEnabled: Bool
    let remainingTime: Int
    let displayRetry: Bool
    @Binding var code: String
    var retryAction: () -> Void

    private var isCodeDisabled: Bool {
        remainingTime > 0
    }

    var body: some View {
        RegistrationCardView(title: L.registerPhoneCodeInputTitle(),
                             subtitle: .attributed(phoneNumber),
                             subtitlePositionIsBottom: false,
                             iconName: nil,
                             bottomPadding: .zero,
                             content: {
            codeInputView
                .padding(.top, Appearance.GridGuide.padding)
        })
    }

    private var codeInputView: some View {
        VStack {
            IsFocusTextField(
                placeholder: L.verifyPhoneCodeHint(),
                keyboardType: .numberPad,
                text: $code,
                isEnabled: true,
                isFocused: .constant(true)
            )
            .multilineTextAlignment(.leading)
            .foregroundColor(Appearance.Colors.primaryText)
            .keyboardType(.numberPad)
            .padding()
            .background(Appearance.Colors.gray6)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .disabled(!isEnabled)

            if displayRetry {
                Button {
                    retryAction()
                } label: {
                    Text(isCodeDisabled ? "\(L.registerPhoneCodeInputRetry("\(remainingTime)"))" : L.registerPhoneCodeInputSendCode())
                        .foregroundColor(isCodeDisabled ? Appearance.Colors.gray2 : Appearance.Colors.primaryText)
                        .textStyle(isCodeDisabled ? .description : .descriptionBold)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Appearance.GridGuide.point)
                }
                .disabled(isCodeDisabled)
            }
        }
    }
}

struct RegisterPhoneView_CodeInput_Preview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneCodeInputView(phoneNumber: NSAttributedString(string: "+420 720 183 578"),
                                   isEnabled: true,
                                   remainingTime: 30,
                                   displayRetry: true,
                                   code: .constant("1234"),
                                   retryAction: {})
    }
}
