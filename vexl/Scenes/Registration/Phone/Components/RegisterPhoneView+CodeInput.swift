//
//  RegisterPhoneView+CodeInput.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Cleevio

extension RegisterPhoneView {

    struct CodeInputView: View {

        let phoneNumber: String
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
                                 subtitle: L.registerPhoneCodeInputSubtitle(phoneNumber),
                                 iconName: R.image.onboarding.eye.name,
                                 content: phoneInputView.padding(.top, Appearance.GridGuide.largePadding1))
        }

        private var phoneInputView: some View {
            VStack {
                BorderedTextField(placeholder: "", textStyle: .paragraphMedium, text: $code)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .keyboardType(.numberPad)
                    .disabled(!isEnabled)

                if displayRetry {
                    Button {
                        retryAction()
                    } label: {
                        Text(isCodeDisabled ? "\(L.registerPhoneCodeInputRetry("\(remainingTime)"))" : L.registerPhoneCodeInputSendCode())
                            .foregroundColor(isCodeDisabled ? Appearance.Colors.gray2 : Appearance.Colors.purple4)
                            .textStyle(isCodeDisabled ? .paragraph : .paragraphBold)
                            .frame(maxWidth: .infinity)
                            .padding(.top, Appearance.GridGuide.padding)
                    }
                    .disabled(isCodeDisabled)
                }
            }
        }
    }
}

struct RegisterPhoneView_CodeInput_Preview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView.CodeInputView(phoneNumber: "+420 720 183 578",
                                        isEnabled: true,
                                        remainingTime: 30,
                                        displayRetry: true,
                                        code: .constant("1234"),
                                        retryAction: {})
    }
}
