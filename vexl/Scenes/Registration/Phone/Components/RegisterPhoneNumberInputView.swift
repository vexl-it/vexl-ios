//
//  RegisterPhoneView+PhoneInput.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Cleevio

struct RegisterPhoneNumberInputView: View {

    @Binding var phoneNumber: String

    var body: some View {
        RegistrationCardView(title: L.registerPhoneNumberInputTitle(),
                             subtitle: L.registerPhoneNumberInputSubtitle(),
                             subtitlePositionIsBottom: true,
                             iconName: R.image.onboarding.eye.name,
                             content: {
            phoneInputView
                .padding(.top, Appearance.GridGuide.mediumPadding1)
        })
    }

    private var phoneInputView: some View {
        PhoneNumberTextFieldView(placeholder: "",
                                 font: Appearance.TextStyle.paragraphMedium.font,
                                 text: $phoneNumber)
            .foregroundColor(Appearance.Colors.primaryText)
            .keyboardType(.phonePad)
            .padding(Appearance.GridGuide.padding)
            .background(Appearance.Colors.gray6)
            .frame(height: Appearance.GridGuide.largeButtonHeight)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

#if DEBUG || DEVEL

struct RegisterPhone_PhoneInputViewPreview: PreviewProvider {
    static var previews: some View {
        RegisterPhoneNumberInputView(phoneNumber: .constant("123 123 123 123"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
    }
}

#endif
