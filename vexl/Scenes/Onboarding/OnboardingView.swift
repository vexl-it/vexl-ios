//
//  OnboardingView.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import SwiftUI
import Combine
import Cleevio

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack {
            card

            buttons
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    private var card: some View {
        VStack {
            PageControl(numberOfPages: viewModel.numberOfPages,
                        currentIndex: viewModel.selectedIndex)
                .padding([.horizontal, .top], Appearance.GridGuide.smallPadding)

            VStack(alignment: .leading) {
                LottieView(animation: viewModel.onboardingState.animation)

                Text(viewModel.title)
                    .foregroundColor(Appearance.Colors.black1)
                    .textStyle(.h3)
                    .transition(.opacity)
                    .id(viewModel.onboardingState.rawValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Appearance.GridGuide.padding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var buttons: some View {
        HStack(alignment: .center) {
            LargeSolidButton(title: L.skip(),
                             padding: Appearance.GridGuide.mediumPadding1,
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .secondary,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                viewModel.send(action: .showLogin)
            })

            LargeSolidButton(title: viewModel.buttonTitle,
                             font: Appearance.TextStyle.titleSmallBold.font.asFont,
                             style: .main,
                             isFullWidth: true,
                             isEnabled: .constant(true),
                             action: {
                guard viewModel.isLastOnboardingPage else {
                    viewModel.send(action: .showLogin)
                    return
                }

                withAnimation {
                    viewModel.send(action: .next)
                }
            })
        }
    }
}

struct OnboardingViewPreview: PreviewProvider {

    static var previews: some View {
        OnboardingView(viewModel: .init())
            .previewDevice("iPhone 13 Pro")
    }
}
