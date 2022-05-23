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
                SolidButton(Text(L.skip())
                                .padding(.horizontal,
                                         Appearance.GridGuide.mediumPadding1),
                            fullWidth: false,
                            font: Appearance.TextStyle.h3.font.asFont,
                            colors: SolidButtonColor.skip,
                            dimensions: SolidButtonDimension.largeButton,
                            action: {
                    skipAction()
                })

                SolidButton(Text(nextTitle),
                            isEnabled: .constant(true),
                            font: Appearance.TextStyle.h3.font.asFont,
                            colors: SolidButtonColor.welcome,
                            dimensions: SolidButtonDimension.largeButton,
                            action: {
                    nextAction()
                })
            }
        }
    }
}
