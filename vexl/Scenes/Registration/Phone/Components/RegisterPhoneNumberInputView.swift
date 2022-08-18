//
//  RegisterPhoneView+PhoneInput.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import SwiftUI
import Cleevio

struct RegisterPhoneNumberInputView: View {

    @Binding var text: String
    var regionCode: String
    var phoneNumber: String

    var body: some View {
        RegistrationCardView(title: L.registerPhoneNumberInputTitle(),
                             subtitle: L.registerPhoneNumberInputSubtitle(),
                             subtitlePositionIsBottom: true,
                             iconName: R.image.onboarding.eye.name,
                             bottomPadding: Appearance.GridGuide.point,
                             content: {
            phoneInputView
                .padding(.top, Appearance.GridGuide.padding)
        })
    }

    private var phoneInputView: some View {
        PhoneNumberTextFieldView(placeholder: "",
                                 font: Appearance.TextStyle.paragraphMedium.font,
                                 regionCode: regionCode,
                                 phoneNumber: phoneNumber,
                                 text: $text,
                                 isFocus: .constant(true))
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
        RegisterPhoneNumberInputView(text: .constant("+51 999 555 444"),
                                     regionCode: "PE",
                                     phoneNumber: "999 555 444")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
    }
}

#endif
