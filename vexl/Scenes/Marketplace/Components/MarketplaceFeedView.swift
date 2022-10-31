//
//  BuySellInformationView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import SwiftUI

struct MarketplaceFeedView: View {

    @ObservedObject var data: OfferDetailViewData
    let displayFooter: Bool
    let requestAction: (String) -> Void

    var body: some View {
        VStack(spacing: Appearance.GridGuide.point) {
            OfferInformationDetailView(
                data: data,
                useInnerPadding: true,
                showArrowIndicator: true,
                showBackground: true
            )
            .clipShape(
                MarketplaceItemShape(horizontalStartPoint: Appearance.GridGuide.feedAvatarSize.width)
            )
            .padding(.bottom, displayFooter ? 0 : Appearance.GridGuide.point)

            MarketplaceFeedFooterView(attributedTitle: data.attributedOfferTitle,
                                      isRequested: data.isRequested,
                                      friendLevel: data.friendLevel,
                                      offerType: data.offerType,
                                      avatar: data.avatar) {
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
        let data = OfferDetailViewData(offer: .stub)
        let data2 = OfferDetailViewData(offer: .stub)

        return ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack {
                MarketplaceFeedView(data: data,
                                    displayFooter: false,
                                    requestAction: { _ in })
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color.black)

                MarketplaceFeedView(data: data2,
                                    displayFooter: true,
                                    requestAction: { _ in })
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color.black)
            }
        }
    }
}
#endif
