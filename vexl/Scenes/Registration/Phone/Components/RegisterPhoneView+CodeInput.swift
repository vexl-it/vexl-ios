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

        @Binding var code: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("We sent you a code")
                    .textStyle(.h2)

                Text("Enter it bellow to verify +420 720 125 021 ")
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.gray2)
                    .padding(.top, 24)

                phoneInputView
                    .padding(.top, 40)

                Text("Didn’t receive code? Resend in 28s")
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
        RegisterPhoneView.CodeInputView(code: .constant("1234"))
    }
}
