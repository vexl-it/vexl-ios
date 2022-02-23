//
//  OnboardingView+Presentation.swift
//  vexl
//
//  Created by Diego Espinoza on 18/02/22.
//

import SwiftUI

extension OnboardingView {

    enum PresentationState: Int, CaseIterable {
        case friends = 0
        case buyAndSell = 1
        case requestIdentity = 2
    }

    struct OnboardingPresentation: View {

        // MARK: - Bindings

        @Binding var selectedIndex: Int

        // MARK: - Properties

        var title: String

        var presentationState: OnboardingView.PresentationState {
            OnboardingView.PresentationState(rawValue: selectedIndex) ?? .friends
        }

        var body: some View {
            VStack(alignment: .leading) {

                // Remove this Color.black once we have the real Lottie animation
                // This is just a placeholder to keep/perserve the layout until we get the animation.
                Color.black
                    .frame(height: 1)

                Spacer()

                Text(title.uppercased())
                    .foregroundColor(.white)
                    .textStyle(.h2)
                    .transition(.opacity)
                    .id(presentationState.rawValue)
            }
        }
    }
}

struct OnboardingPresentationViewPreview: PreviewProvider {

    static var previews: some View {
        OnboardingView.OnboardingPresentation(selectedIndex: .constant(0), title: "This is a title")
            .background(Color.black)
            .previewDevice("iPhone 13 Pro")
    }
}
