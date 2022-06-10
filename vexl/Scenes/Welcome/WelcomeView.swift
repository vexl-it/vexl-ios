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
                .padding(.top, Appearance.GridGuide.largePadding1)

            VStack {
                title
                    .padding(.horizontal, Appearance.GridGuide.mediumPadding2)

                AgreementSwitch(text: L.welcomeTermsAgreements(),
                                links: [L.welcomeTermsAgreementsLink(): L.welcomeTermsAgreementsUrl()],
                                isOn: $viewModel.hasAgreedTermsAndConditions)
                    .padding(.horizontal, Appearance.GridGuide.largePadding1)
                    .padding(.bottom, Appearance.GridGuide.largePadding1)
                    .padding(.top, Appearance.GridGuide.largePadding1)

                LargeSolidButton(title: L.continue(),
                                 font: Appearance.TextStyle.titleSmallBold.font.asFont,
                                 style: .custom(color: .welcome),
                                 isFullWidth: true,
                                 isEnabled: $viewModel.hasAgreedTermsAndConditions,
                                 action: {
                    viewModel.send(action: .continueTap)
                })
                    .padding(.horizontal, Appearance.GridGuide.padding)
            }.frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var title: some View {
        Text(L.welcomeTitle())
            .textStyle(.h3)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
    }
}

struct WelcomeViewPreview: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: .init())
            .previewDevice("iPhone 11")
    }
}
