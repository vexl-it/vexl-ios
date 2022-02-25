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
        @Binding var code: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(L.registerPhoneCodeInputTitle())
                    .textStyle(.h2)

                Text(L.registerPhoneCodeInputSubtitle(phoneNumber))
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.gray2)
                    .padding(.top, 24)

                phoneInputView
                    .padding(.top, 40)

                Text("\(L.registerPhoneCodeInputRetry("28s"))")
                    .foregroundColor(Appearance.Colors.gray2)
                    .textStyle(.paragraph)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Appearance.GridGuide.padding)
            }
            .padding(.all, Appearance.GridGuide.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(CardViewModifier())
        }

        private var phoneInputView: some View {
            HStack {
                TextField("", text: $code)
                    .multilineTextAlignment(.center)
                    .textStyle(.h3)
                    .keyboardType(.numberPad)
            }
            .padding()
            .makeCorneredBorder(color: Appearance.Colors.gray3, borderWidth: 1)
        }
    }
}

struct RegisterPhoneView_CodeInput_Preview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView.CodeInputView(phoneNumber: "+420 720 183 578",
                                        code: .constant("1234"))
    }
}
