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
        var pickerTap: () -> Void

        var body: some View {
            RegistrationCardView(title: L.registerPhoneNumberInputTitle(),
                                 subtitle: L.registerPhoneNumberInputSubtitle(),
                                 iconName: R.image.onboarding.eye.name,
                                 content: phoneInputView.padding(.top, Appearance.GridGuide.largePadding1))
        }

        private var phoneInputView: some View {
            HStack {
                TextField("", text: $phoneNumber)
                    .textStyle(.h3)
                    .foregroundColor(Appearance.Colors.primaryText)
                    .keyboardType(.phonePad)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .makeCorneredBorder(color: Appearance.Colors.gray3, borderWidth: 1)
        }
    }
}
