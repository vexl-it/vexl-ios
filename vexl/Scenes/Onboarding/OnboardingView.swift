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

    // MARK: Onboarding Pages

    private let skipWidth: CGFloat = 87

    private var numberOfPages: Int {
        PresentationState.allCases.count
    }

    private var titleButton: String {
        viewModel.presentationState == .requestIdentity ? "Got it!" : "Next"
    }

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.vertical)

            VStack {
                PageControl(numberOfPages: numberOfPages, currentIndex: $viewModel.selectedIndex)

                Spacer()

                OnboardingPresentation(presentationState: $viewModel.presentationState)
                    .padding(.vertical, Appearance.GridGuide.mediumPadding)

                Spacer()

                bottomButtons
            }
            .padding(.horizontal, Appearance.GridGuide.padding)
        }
    }

    private var bottomButtons: some View {
        HStack(alignment: .center) {
            SolidButton(Text("Skip"),
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.skip,
                        dimensions: SolidButtonDimension.largeButton,
                        action: {
                viewModel.send(action: .showLogin)
            })
            .frame(width: skipWidth)

            SolidButton(Text(titleButton),
                        isEnabled: .constant(true),
                        font: Appearance.TextStyle.h3.font.asFont,
                        colors: SolidButtonColor.welcome,
                        dimensions: SolidButtonDimension.largeButton,
                        action: {
                guard viewModel.selectedIndex < numberOfPages - 1 else {
                    viewModel.send(action: .showLogin)
                    return
                }
                guard let nextState = PresentationState(rawValue: viewModel.selectedIndex + 1) else { return }
                withAnimation {
                    viewModel.send(action: .next(state: nextState))
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
