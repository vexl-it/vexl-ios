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
            PhoneNumberTextFieldView(placeholder: "",
                                     font: Appearance.TextStyle.paragraphMedium.font,
                                     text: $phoneNumber)
                .foregroundColor(Appearance.Colors.primaryText)
                .keyboardType(.phonePad)
                .padding(Appearance.GridGuide.padding)
                .frame(height: Appearance.GridGuide.largeButtonHeight)
                .makeCorneredBorder(color: Appearance.Colors.gray3, borderWidth: 1)
        }
    }
}

#if DEBUG || DEVEL

struct RegisterPhone_PhoneInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneView.PhoneInputView(phoneNumber: .constant("123 123 123 123"),
                                         pickerTap: {})
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
    }
}

#endif
