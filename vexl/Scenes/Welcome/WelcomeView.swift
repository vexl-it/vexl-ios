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

                SolidButton(Text(L.continue()),
                            isEnabled: $viewModel.hasAgreedTermsAndConditions,
                            font: Appearance.TextStyle.h3.font.asFont,
                            colors: SolidButtonColor.welcome,
                            dimensions: SolidButtonDimension.largeButton) {
                    viewModel.send(action: .continueTap)
                }.padding(.horizontal, Appearance.GridGuide.padding)
            }.frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var title: some View {
        Text(L.welcomeTitle())
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
