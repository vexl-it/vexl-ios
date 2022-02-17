//
//  LoginView+Agreement.swift
//  vexl
//
//  Created by Diego Espinoza on 17/02/22.
//

import SwiftUI

extension WelcomeView {

    struct AgreementSwitch: View {
        let text: String
        let links: [String: String]
        @Binding var isOn: Bool

        var body: some View {
            HStack(alignment: .center) {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Appearance.Colors.purple5))

                // TODO: - Localize text in the google sheet when created

                LinkTextView(text: "I agree to Terms and Privacy",
                             links: ["Terms and Privacy": "https://google.com"],
                             font: Appearance.TextStyle.paragraph.font,
                             linkFont: Appearance.TextStyle.paragraphBold.font,
                             textColor: UIColor(Appearance.Colors.gray3),
                             linkColor: UIColor.white,
                             textAlignment: .center)
            }
        }
    }
}
