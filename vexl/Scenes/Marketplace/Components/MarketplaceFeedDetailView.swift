//
//  BuySellFeedDetailView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct MarketplaceFeedDetailView: View {

    let maxAmount: String
    let paymentMethod: String
    let fee: String?

    var body: some View {
        HStack {
            DetailItem(label: "To sell", content: {
                Text(L.marketplaceDetailUpTo(maxAmount))
                    .foregroundColor(Appearance.Colors.gray2)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            })
                .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)

            DetailItem(label: "Payment", content: {
                PaymentIconView(
                    icons: [
                        R.image.marketplace.revolut.name
                    ]
                )
            })
                .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)

            DetailItem(label: "Prague", content: {
                Image(R.image.marketplace.mapPin.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.feedIconSize)
            })
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, Appearance.GridGuide.padding)
    }
}

extension MarketplaceFeedDetailView {

    private struct PaymentIconView: View {

        let icons: [String]

        var body: some View {
            if icons.count == 1 || icons.count > 3 {
                Image(icons[0])
                    .frame(size: Appearance.GridGuide.feedIconSize)
            } else if icons.count == 2 {
                HStack(spacing: .zero) {
                    Image(icons[0])
                        .resizable()
                        .frame(size: Appearance.GridGuide.feedMediumIconSize)
                    Image(icons[1])
                        .resizable()
                        .frame(size: Appearance.GridGuide.feedMediumIconSize)
                }
            } else if icons.count == 3 {
                VStack(spacing: .zero) {
                    Image(icons[0])
                        .resizable()
                        .frame(size: Appearance.GridGuide.feedSmallIconSize)
                    HStack(spacing: .zero) {
                        Image(icons[1])
                            .resizable()
                            .frame(size: Appearance.GridGuide.feedSmallIconSize)
                        Image(icons[2])
                            .resizable()
                            .frame(size: Appearance.GridGuide.feedSmallIconSize)
                    }
                }
            } else {
                Text(Constants.notAvailable)
                    .textStyle(.paragraphBold)
                    .foregroundColor(Appearance.Colors.gray3)
            }
        }
    }

    private struct DetailItem<Content: View>: View {

        let label: String
        let content: () -> Content

        var body: some View {
            VStack {
                content()
                    .frame(maxHeight: .infinity)

                Text(label)
                    .textStyle(.descriptionSemiBold)
                    .foregroundColor(Appearance.Colors.gray3)
                    .padding(.top, Appearance.GridGuide.point)
            }
        }
    }
}

#if DEBUG || DEVEL
struct MarketplaceFeedDetailViewPreview: PreviewProvider {
    static var previews: some View {
        MarketplaceFeedDetailView(maxAmount: "$10k",
                                  paymentMethod: "Revolut",
                                  fee: "Wants $30 fee per transaction")
            .frame(height: 100)
            .previewDevice("iPhone 11")
    }
}
#endif
