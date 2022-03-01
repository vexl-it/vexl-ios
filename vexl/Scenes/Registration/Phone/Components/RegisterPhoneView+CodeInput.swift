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
        @Binding var code: String

        var body: some View {
            RegistrationCardView(title: L.registerPhoneCodeInputTitle(),
                                 subtitle: L.registerPhoneCodeInputSubtitle(phoneNumber),
                                 content: phoneInputView.padding(.top, Appearance.GridGuide.largePadding1))
        }

        private var phoneInputView: some View {
            VStack {
                BorderedTextField(placeholder: "", text: $code)
                    .multilineTextAlignment(.center)
                    .textStyle(.h3)
                    .keyboardType(.numberPad)
                    .disabled(!isEnabled)

                // TODO: Add countdown after to show retry timer

                Text("\(L.registerPhoneCodeInputRetry("28s"))")
                    .foregroundColor(Appearance.Colors.gray2)
                    .textStyle(.paragraph)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Appearance.GridGuide.padding)
            }
        }
    }
}

struct RegisterPhoneView_CodeInput_Preview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView.CodeInputView(phoneNumber: "+420 720 183 578",
                                        isEnabled: true,
                                        code: .constant("1234"))
    }
}
