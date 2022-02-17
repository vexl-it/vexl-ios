//
//  LoginView.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import SwiftUI
import Combine
import Cleevio

struct WelcomeView: View {

    @ObservedObject var viewModel: WelcomeViewModel

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
                .edgesIgnoringSafeArea(.vertical)

            LogoImageView()
                .padding(.top, Appearance.GridGuide.largePadding)

            VStack {
                title
                    .padding(.horizontal, Appearance.GridGuide.mediumPadding)

                // TODO: - Localize text in the google sheet when created

                AgreementSwitch(text: "I agree to Terms and Privacy",
                                links: ["Terms and Privacy": "https://google.com"],
                                isOn: $viewModel.hasAgreedTermsAndConditions)
                    .padding(.horizontal, Appearance.GridGuide.largePadding)
                    .padding(.bottom, Appearance.GridGuide.largePadding)
                    .padding(.top, Appearance.GridGuide.largePadding)

                // TODO: - Localize text in the google sheet when created

                LargeButton(title: "Continue",
                            backgroundColor: Appearance.Colors.purple5,
                            isEnabled: viewModel.hasAgreedTermsAndConditions,
                            action: {
                    viewModel.send(action: .continueTap)
                })
                    .padding(.horizontal, Appearance.GridGuide.padding)
            }.frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var title: some View {
        // TODO: - Localize text in the google sheet when created
        Text("That’s it, ready to get started?")
            .textStyle(.h2)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .lineLimit(2)
    }
}

struct WelcomeViewPreview: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
