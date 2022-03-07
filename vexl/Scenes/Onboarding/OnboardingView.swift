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
            PageControl(numberOfPages: viewModel.numberOfPages, currentIndex: $viewModel.selectedIndex)

            Spacer()

            OnboardingPresentation(selectedIndex: $viewModel.selectedIndex,
                                   title: viewModel.title)
                .padding(.vertical, Appearance.GridGuide.mediumPadding2)

            Spacer()

            ButtonBarView(nextTitle: viewModel.buttonTitle,
                          skipAction: {
                viewModel.send(action: .showLogin)
            },
                          nextAction: {
                guard viewModel.isLastOnboardingPage else {
                    viewModel.send(action: .showLogin)
                    return
                }

                withAnimation {
                    viewModel.send(action: .next)
                }
            })
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct OnboardingViewPreview: PreviewProvider {

    static var previews: some View {
        OnboardingView(viewModel: .init())
            .previewDevice("iPhone 13 Pro")
    }
}
