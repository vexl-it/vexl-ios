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

    private var blackCircleSize: CGSize {
        CGSize(width: 175.adjusted, height: 175.adjusted)
    }

    private var whiteCircleSize: CGSize {
        CGSize(width: 160.adjusted, height: 160.adjusted)
    }

    private var yellowCircleSize: CGSize {
        CGSize(width: 170.adjusted, height: 170.adjusted)
    }

    private var countdown: some View {
        VStack(spacing: Appearance.GridGuide.padding.adjusted) {

            countdownCircle

            Text(L.lockedScreenContactsRemaining())
                .minimumScaleFactor(0.75)
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .font(R.font.ttSatoshiDemiBold(size: 18)?.asFont)

            Text(L.lockedScreenTitle())
                .minimumScaleFactor(0.75)
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .font(R.font.ttSatoshiDemiBold(size: 18)?.asFont)

            HLine(color: Appearance.Colors.gray3, height: 1)
                .padding(.vertical, Appearance.GridGuide.point.adjusted)

            Text(L.lockedScreenSubtitle())
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .font(R.font.ttSatoshiRegular(size: 16)?.asFont)

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
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, UIScreen.isSmallScreen ? 0 : Appearance.GridGuide.mediumPadding1)
    }

    private var countdownCircle: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.black, lineWidth: 5)
                .frame(size: blackCircleSize)
                .background(
                    Circle()
                        .foregroundColor(Color.white)
                        .frame(size: whiteCircleSize)
                )
                .overlay(
                    Text("\(Constants.numberOfOffersForLockedScreen)")
                        .font(R.font.ttSatoshiMedium(size: 32.adjusted)?.asFont)
                )

            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(Appearance.Colors.yellow100, style: StrokeStyle(lineWidth: 5))
                .frame(size: yellowCircleSize)
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
