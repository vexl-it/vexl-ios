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
                BorderedTextField(placeholder: "", text: $code)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .textStyle(.h3)
                    .keyboardType(.numberPad)
                    .disabled(!isEnabled)

                Button {
                    retryAction()
                } label: {
                    Text(isCodeDisabled ? "\(L.registerPhoneCodeInputRetry("\(remainingTime)"))" : "Send Code Again")
                        .foregroundColor(isCodeDisabled ? Appearance.Colors.gray2 : Appearance.Colors.purple4)
                        .textStyle(.paragraph)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Appearance.GridGuide.padding)
                }
                .disabled(isCodeDisabled)
            }
        }
    }
}

struct RegisterPhoneView_CodeInput_Preview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView.CodeInputView(phoneNumber: "+420 720 183 578",
                                        isEnabled: true,
                                        remainingTime: 30,
                                        code: .constant("1234"),
                                        retryAction: {})
    }
}
