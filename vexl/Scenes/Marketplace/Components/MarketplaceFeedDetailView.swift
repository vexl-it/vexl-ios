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
    let paymentLabel: String
    let paymentIcons: [String]
    let fee: String?
    let offerType: OfferType

    private var paymentLayoutStyle: MarketplacePaymentIconView.LayoutStyle {
        MarketplacePaymentIconView.LayoutStyle(icons: paymentIcons)
    }

    var body: some View {
        HStack {
            DetailItem(label: offerType == .buy ? L.marketplaceDetailBuy() : L.marketplaceDetailSell(), content: {
                Text(L.marketplaceDetailUpTo(maxAmount))
                    .foregroundColor(Appearance.Colors.gray2)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            })
                .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)

            DetailItem(label: paymentLabel, content: {
                MarketplacePaymentIconView(layoutStyle: paymentLayoutStyle)
            })
                .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)

            // TODO: - Set real location when it is implemented

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
                                  paymentLabel: "Revolut",
                                  paymentIcons: [R.image.marketplace.revolut.name],
                                  fee: "Wants $30 fee per transaction",
                                  offerType: .sell)
            .frame(height: 100)
            .previewDevice("iPhone 11")
    }
}
#endif
