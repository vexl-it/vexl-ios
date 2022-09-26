//
//  OfferSettingsProgressView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/09/22.
//

import SwiftUI

struct OfferSettingsProgressView: View {
    let currentValue: Int
    let maxValue: Int

    private var percentage: String {
        let percentage = Double(currentValue) / Double(maxValue)
        return Formatters.percentageFormatter.string(from: NSNumber(value: percentage)) ?? Constants.notAvailable
    }

    private var progressText: String {
        if inProgress {
            return L.offerProgressBarTitle("\(maxValue)")
        } else {
            return L.offerProgressBarTitleComplete("\(maxValue)")
        }
    }

    private var progressTitle: String {
        if inProgress {
            return L.offerProgressTitleLoading()
        } else {
            return L.offerProgressTitleComplete()
        }
    }

    private var inProgress: Bool {
        currentValue < maxValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Appearance.GridGuide.smallPadding) {
            Text(progressTitle)
                .textStyle(.h2)
                .foregroundColor(Appearance.Colors.black1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            ProgressView(value: CGFloat(currentValue), total: CGFloat(maxValue))
                .progressViewStyle(
                    LinearProgressViewStyle(tint: Appearance.Colors.black1)
                )

            HStack {
                Text(progressText)
                    .foregroundColor(Appearance.Colors.black1)
                    .textStyle(.descriptionBold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if inProgress {
                    Text(L.offerProgressBarSubtitle(percentage))
                        .foregroundColor(Appearance.Colors.gray3)
                        .textStyle(.description)
                }
            }
                .padding(.bottom, Appearance.GridGuide.smallPadding)

            Text(L.offerProgressSubtitle())
                .textStyle(.paragraph)
                .foregroundColor(Appearance.Colors.gray3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
        .padding(.horizontal, Appearance.GridGuide.smallPadding)
    }
}

#if DEBUG || DEVEL

struct OfferSettingsProgressViewPreview: PreviewProvider {
    struct OfferSettingsTestView: View {
        var body: some View {
            VStack {
                Text("This is a test")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay(
                OfferSettingsProgressView(currentValue: 100, maxValue: 1_000)
            )
        }
    }

    static var previews: some View {
        OfferSettingsTestView()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .previewDevice("iPhone 11")

        OfferSettingsProgressView(currentValue: 100, maxValue: 1_000)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .previewDevice("iPhone 11")
    }
}

#endif
