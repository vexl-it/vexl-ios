//
//  LoginView+Agreement.swift
//  vexl
//
//  Created by Diego Espinoza on 17/02/22.
//

import SwiftUI

struct WelcomeAgreementSwitch: View {
    @Binding var isOn: Bool
    var linkAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: Appearance.GridGuide.padding) {
            Image(R.image.onboarding.welcomeNote.name)

            agreementLink

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Appearance.Colors.yellow100))
        }
        .padding()
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var agreementLink: some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            Text(L.welcomeTermsAgreementsOne())
                .textStyle(.paragraphMedium)
                .foregroundColor(Appearance.Colors.gray3)
            +
            Text(" ")
            +
            Text(L.welcomeTermsAgreementsTwo())
                .textStyle(.paragraphMedium)
                .foregroundColor(Appearance.Colors.whiteText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            linkAction()
        }
    }
}

#if DEVEL || DEBUG

struct WelcomeAgreementSwitchPreview: PreviewProvider {
    static var previews: some View {
        WelcomeAgreementSwitch(isOn: .constant(true)) {}
            .padding(.horizontal, Appearance.GridGuide.point)
    }
}

#endif
