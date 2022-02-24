//
//  RegisterPhoneView+PhoneInput.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Cleevio

extension RegisterPhoneView {

    struct PhoneInputView: View {

        @Binding var phoneNumber: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("What’s your phone number?")
                    .textStyle(.h2)

                Text("Your number will be anonymous")
                    .textStyle(.paragraph)
                    .foregroundColor(Appearance.Colors.gray2)
                    .padding(.top, 24)

                phoneInputView
                    .padding(.top, 40)
            }
            .padding(.all, Appearance.GridGuide.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(CardViewModifier())
        }

        private var phoneInputView: some View {
            HStack {
                Text("🇨🇿")
                    .textStyle(.h3)

                Text("+420")
                    .textStyle(.h3)
                    .foregroundColor(Appearance.Colors.gray2)

                TextField("", text: $phoneNumber)
                    .textStyle(.h3)
                    .keyboardType(.numberPad)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .makeCorneredBorder(color: Appearance.Colors.gray3, borderWidth: 1)
        }
    }
}
