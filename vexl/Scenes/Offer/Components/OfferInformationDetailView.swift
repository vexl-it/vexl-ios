//
//  OfferInformationDetailView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct OfferInformationDetailView: View {
    let title: String
    let maxAmount: String
    let paymentLabel: String
    let paymentIcons: [String]
    let offerType: OfferType
    let isRequested: Bool
    @State private var lineSize: CGSize = .zero

    private var paymentLayoutStyle: MarketplacePaymentIconView.LayoutStyle {
        MarketplacePaymentIconView.LayoutStyle(icons: paymentIcons)
    }

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            Text(title)
                .textStyle(.paragraph)
                .multilineTextAlignment(.leading)
                .foregroundColor(isRequested ? Appearance.Colors.gray3 : Appearance.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Appearance.GridGuide.mediumPadding1)

            detail
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
        .background(isRequested ? Appearance.Colors.gray1 : Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    private var detail: some View {
        HStack {
            DetailItem(label: offerType == .buy ? L.marketplaceDetailBuy() : L.marketplaceDetailSell(), content: {
                Text(L.marketplaceDetailUpTo(maxAmount))
                    .foregroundColor(Appearance.Colors.gray2)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            })
            .readSize(onChange: { size in
                lineSize = size
            })
            .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)
                .frame(maxHeight: lineSize.height)

            DetailItem(label: paymentLabel, content: {
                MarketplacePaymentIconView(layoutStyle: paymentLayoutStyle)
            })
            .frame(maxWidth: .infinity)

            VLine(color: Appearance.Colors.gray4, width: 1)
                .frame(maxHeight: lineSize.height)

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

extension OfferInformationDetailView {

    private struct DetailItem<Content: View>: View {
        let label: String
        let content: () -> Content
        private let maxHeight: CGFloat = 80

        var body: some View {
            VStack {
                content()
                    .frame(maxHeight: maxHeight)

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
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            OfferInformationDetailView(
                title: "Test df",
                maxAmount: "$10k",
                paymentLabel: "Revolut",
                paymentIcons: [R.image.marketplace.revolut.name],
                offerType: .sell,
                isRequested: true
            )
            .frame(height: 250)
        }
    }
}
#endif
