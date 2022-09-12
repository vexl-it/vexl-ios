//
//  LockedScreenView.swift
//  vexl
//
//  Created by Diego Espinoza on 25/08/22.
//

import SwiftUI

struct LockedScreenView: View {

    let viewModel: LockedScreenViewModel = .init()

    let sellingAction: () -> Void
    let buyingAction: () -> Void

    var body: some View {
        countdown
    }

    private var blackCircleSize: CGSize {
        CGSize(width: 145.adjusted, height: 145.adjusted)
    }

    private var whiteCircleSize: CGSize {
        CGSize(width: 130.adjusted, height: 130.adjusted)
    }

    private var yellowCircleSize: CGSize {
        CGSize(width: 140.adjusted, height: 140.adjusted)
    }

    private var title: Font? {
        R.font.ttSatoshiMedium(size: 32.adjusted)?.asFont
    }

    private var subtitle: Font? {
        R.font.ttSatoshiDemiBold(size: 18)?.asFont
    }

    private var paragraph: Font? {
        R.font.ttSatoshiRegular(size: 16)?.asFont
    }

    private var countdown: some View {
        VStack(spacing: Appearance.GridGuide.padding.adjusted) {
            countdownCircle

            Text(L.lockedScreenContactsRemaining())
                .minimumScaleFactor(0.75)
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .font(subtitle)

            Text(L.lockedScreenTitle())
                .minimumScaleFactor(0.75)
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .font(subtitle)

            HLine(color: Appearance.Colors.gray3, height: 1)
                .padding(.vertical, Appearance.GridGuide.point.adjusted)

            Text(L.lockedScreenSubtitle())
                .foregroundColor(Appearance.Colors.whiteText)
                .multilineTextAlignment(.center)
                .font(paragraph)

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
        .padding(.horizontal, Appearance.GridGuide.padding)
        .frame(maxHeight: .infinity, alignment: .center)
        .padding(.top, UIScreen.isSmallScreen ? 0 : Appearance.GridGuide.mediumPadding1)
        .padding(.bottom, Appearance.GridGuide.homeTabBarHeight)
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
                    Text("\(viewModel.currentRemainingContactsCount)")
                        .font(title)
                )

            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(Appearance.Colors.yellow100, style: StrokeStyle(lineWidth: 5))
                .frame(size: yellowCircleSize)
                .rotationEffect(.degrees(270))
        }
    }
}

class LockedScreenViewModel {
    @Inject var remoteConfig: RemoteConfigManagerType

    let totalContactsCount: CGFloat = 130_000

    var currentRemainingContactsCount: Int {
        remoteConfig.getIntValue(for: .remainingConstacts)
    }

    var progress: CGFloat {
        (1.0 - (CGFloat(currentRemainingContactsCount) / totalContactsCount)).clamped(from: 0, to: 1)
    }
}

struct LockedScreenViewPreview: PreviewProvider {

    static var previews: some View {
        LockedScreenView(sellingAction: {},
                         buyingAction: {})
            .previewDevice(.init(rawValue: "iPhone 13 Pro"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        LockedScreenView(sellingAction: {},
                         buyingAction: {})
            .previewDevice(.init(rawValue: "iPhone 5S"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
