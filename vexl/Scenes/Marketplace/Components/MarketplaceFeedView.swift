//
//  BuySellInformationView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import SwiftUI

struct MarketplaceFeedView: View {

    let data: OfferDetailViewData
    let displayFooter: Bool
    let detailAction: (String) -> Void
    let requestAction: (String) -> Void

    var body: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferInformationDetailView(
                data: data,
                useInnerPadding: true,
                showBackground: true
            )
            .padding(.bottom, displayFooter ? 0 : Appearance.GridGuide.padding)
            .onTapGesture {
                detailAction(data.id)
            }

            MarketplaceFeedFooterView(username: data.username,
                                      isRequested: data.isRequested,
                                      friendLevel: data.friendLevel,
                                      offerType: data.offerType) {
                requestAction(data.id)
            }
            .padding(.bottom, Appearance.GridGuide.padding)
        }
        .padding(.horizontal, Appearance.GridGuide.point)
    }
}

#if DEBUG || DEVEL
struct MarketplaceFeedViewViewPreview: PreviewProvider {
    static var previews: some View {
        let data = OfferDetailViewData(
            id: "1",
            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
            isRequested: false,
            friendLevel: "Friend",
            amount: "$10k",
            paymentMethods: [.revolut, .bank],
            fee: nil,
            offerType: .sell
        )

        let data2 = OfferDetailViewData(
            id: "2",
            title: "I’ll be wearing a red hat, Don’t text me before 9am — I love to sleep...",
            isRequested: true,
            friendLevel: "Friend",
            amount: "$10k",
            paymentMethods: [.revolut],
            fee: nil,
            offerType: .buy
        )

        return ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack {
                MarketplaceFeedView(data: data,
                                    displayFooter: false,
                                    detailAction: { _ in },
                                    requestAction: { _ in })
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color.black)

                MarketplaceFeedView(data: data2,
                                    displayFooter: true,
                                    detailAction: { _ in },
                                    requestAction: { _ in })
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color.black)
            }
        }
    }
}
#endif
