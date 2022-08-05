//
//  LoginView+Agreement.swift
//  vexl
//
//  Created by Diego Espinoza on 17/02/22.
//

import SwiftUI

struct WelcomeAgreementSwitch: View {
    let text: String
    let links: [String: String]
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: Appearance.GridGuide.mediumPadding1) {
            Image(R.image.onboarding.welcomeNote.name)

            LinkTextView(text: L.welcomeTermsAgreements(),
                         links: [L.welcomeTermsAgreementsLink(): L.welcomeTermsAgreementsUrl()],
                         font: Appearance.TextStyle.paragraph.font,
                         linkFont: Appearance.TextStyle.paragraph.font,
                         textColor: UIColor(Appearance.Colors.gray3),
                         linkColor: UIColor.white,
                         textAlignment: .left)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Appearance.Colors.yellow100))
        }
        .padding()
        .background(Appearance.Colors.gray1)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

#if DEVEL || DEBUG

struct WelcomeAgreementSwitchPreview: PreviewProvider {
    static var previews: some View {
        WelcomeAgreementSwitch(text: "hello",
                               links: [:],
                               isOn: .constant(true))
            .previewDevice("iPhone 11")
    }
}

#endif
