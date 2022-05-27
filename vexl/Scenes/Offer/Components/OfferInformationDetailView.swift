//
//  OfferInformationDetailView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct OfferInformationDetailView: View {
    let data: OfferDetailViewData
    let useInnerPadding: Bool
    let showBackground: Bool
    @State private var lineSize: CGSize = .zero

    private var paymentLayoutStyle: OfferPaymentIconView.LayoutStyle {
        OfferPaymentIconView.LayoutStyle(icons: data.paymentIcons)
    }

    private var backgroundColor: Color {
        guard showBackground else {
            return Color.clear
        }
        return data.isRequested ? Appearance.Colors.gray1 : Appearance.Colors.whiteText
    }
cl
    private var textColor: Color {
        guard showBackground else {
            return Appearance.Colors.primaryText
        }
        return data.isRequested ? Appearance.Colors.gray3 : Appearance.Colors.primaryText
    }

    var body: some View {
        VStack(spacing: Appearance.GridGuide.padding) {
            Text(data.title)
                .textStyle(.paragraphMedium)
                .multilineTextAlignment(.leading)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, useInnerPadding ? Appearance.GridGuide.mediumPadding1 : 0)

            detail
        }
        .padding(.horizontal, useInnerPadding ? Appearance.GridGuide.padding : 0)
        .background(backgroundColor)
        .cornerRadius(showBackground ? Appearance.GridGuide.buttonCorner : 0)
    }

    private var detail: some View {
        HStack {
            DetailItem(label: data.offerType == .buy ? L.marketplaceDetailBuy() : L.marketplaceDetailSell(), content: {
                Text(L.marketplaceDetailUpTo(data.amount))
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

            DetailItem(label: data.paymentLabel, content: {
                OfferPaymentIconView(layoutStyle: paymentLayoutStyle)
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
        .padding(.bottom, useInnerPadding ? Appearance.GridGuide.padding : 0)
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
                data: .stub,
                useInnerPadding: false,
                showBackground: true
            )
            .frame(height: 250)
        }
    }
}
#endif
