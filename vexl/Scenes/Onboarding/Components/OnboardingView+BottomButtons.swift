//
//  OnboardingView+BottomButtons.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import SwiftUI
import Cleevio

extension OnboardingView {

    struct ButtonBarView: View {

        var nextTitle: String
        var skipAction: () -> Void
        var nextAction: () -> Void

        var body: some View {
            HStack(alignment: .center) {
                LargeSolidButton(title: L.skip(),
                                 font: Appearance.TextStyle.h3.font.asFont,
                                 style: .custom(color: .skip),
                                 isFullWidth: false,
                                 isEnabled: .constant(true),
                                 action: {
                    skipAction()
                })

                LargeSolidButton(title: nextTitle,
                                 font: Appearance.TextStyle.h3.font.asFont,
                                 style: .custom(color: .welcome),
                                 isFullWidth: true,
                                 isEnabled: .constant(true),
                                 action: {
                    nextAction()
                })
            }
        }
    }
}

struct OnboardingButtonBarViewPreview: PreviewProvider {

    static var previews: some View {
        OnboardingView.ButtonBarView(nextTitle: "Next", skipAction: {}, nextAction: {})
            .background(Color.black)
            .previewDevice("iPhone 13 Pro")
    }
}
