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
        VStack(spacing: .zero) {
            card
                .padding(.horizontal, Appearance.GridGuide.point)

            WelcomeAgreementSwitch(isOn: $viewModel.hasAgreedTermsAndConditions) {
                viewModel.action.send(.linkTap)
            }
                .padding(.vertical, Appearance.GridGuide.smallPadding)
                .padding(.horizontal, Appearance.GridGuide.point)

            LargeSolidButton(title: L.continue(),
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: $viewModel.hasAgreedTermsAndConditions,
                             action: {
                viewModel.send(action: .continueTap)
            })
                .padding(.horizontal, Appearance.GridGuide.point)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var card: some View {
        VStack(spacing: .zero) {
            Image(R.image.onboarding.welcomeVexl.name)
                .resizable()
                .scaledToFit()
                .padding(.vertical, Appearance.GridGuide.largePadding1)

            Text(L.welcomeProductName())
                .foregroundColor(Appearance.Colors.primaryText)
                .textStyle(.largeTitle)
                .padding(.bottom, Appearance.GridGuide.mediumPadding1)

            Text(L.welcomeTitle())
                .textStyle(.paragraphMedium)
                .multilineTextAlignment(.center)
                .foregroundColor(Appearance.Colors.gray3)
                .padding(.bottom, Appearance.GridGuide.point)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

#if DEVEL || DEBUG

struct WelcomeViewPreview: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: .init())
    }
}

#endif
