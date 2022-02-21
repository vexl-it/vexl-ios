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

        var title: String {
            switch self {
            case .friends:
                return "import your friends anonymously."
            case .buyAndSell:
                return "see their buy & sell offers."
            case .requestIdentity:
                return "request identity for the ones you like and trade."
            }
        }
    }

    struct OnboardingPresentation: View {

        @Binding var presentationState: OnboardingView.PresentationState

        var body: some View {
            VStack(alignment: .leading) {
                
                Color.red
                    .frame(height: 250)
                
                Spacer()
                
                Text(presentationState.title.uppercased())
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
        OnboardingView.OnboardingPresentation(presentationState: .constant(.friends))
            .background(Color.black)
            .previewDevice("iPhone 13 Pro")
    }
}
