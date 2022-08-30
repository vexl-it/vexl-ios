//
//  LockedScreenView.swift
//  vexl
//
//  Created by Diego Espinoza on 25/08/22.
//

import SwiftUI

struct LockedScreenView: View {

    let sellingAction: () -> Void
    let buyingAction: () -> Void

    var body: some View {
        countdown
    }

    private var countdown: some View {
        VStack(spacing: Appearance.GridGuide.padding) {

            countdownCircle

            Text(L.lockedScreenTitle())
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .textStyle(.paragraphSemibold)

            HLine(color: Appearance.Colors.gray3, height: 1)
                .padding(.vertical, Appearance.GridGuide.point)

            Text(L.lockedScreenSubtitle())
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .textStyle(.paragraphSmall)

            HStack {
                LargeSolidButton(
                    title: L.lockedScreenSell(),
                    font: Appearance.TextStyle.descriptionBold.font.asFont,
                    style: .main,
                    isFullWidth: true,
                    height: .regularButton,
                    isEnabled: .constant(true),
                    action: {
                        sellingAction()
                    }
                )

                LargeSolidButton(
                    title: L.lockedScreenBuy(),
                    font: Appearance.TextStyle.descriptionBold.font.asFont,
                    style: .main,
                    isFullWidth: true,
                    height: .regularButton,
                    isEnabled: .constant(true),
                    action: {
                        buyingAction()
                    }
                )
            }
        }
        .padding(.horizontal, Appearance.GridGuide.mediumPadding2)
    }

    private var countdownCircle: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.black, lineWidth: 5)
                .frame(size: CGSize(width: 128, height: 128))
                .background(
                    Circle()
                        .foregroundColor(Color.white)
                        .frame(width: 110, height: 110)
                )
                .overlay(
                    VStack {
                        Text("\(Constants.numberOfOffersForLockedScreen)")
                            .textStyle(.h3)

                        Text(L.lockedScreenOffers())
                            .textStyle(.paragraphSmall)
                            .foregroundColor(Appearance.Colors.gray3)
                    }
                )

            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(Appearance.Colors.yellow100, style: StrokeStyle(lineWidth: 5))
                .frame(size: CGSize(width: 123, height: 123))
                .rotationEffect(.degrees(270))
        }
    }
}

struct LockedScreenViewPreview: PreviewProvider {

    static var previews: some View {
        LockedScreenView(sellingAction: {},
                         buyingAction: {})
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}