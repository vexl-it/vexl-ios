//
//  BuySellFeedDetailFooterView.swift
//  vexl
//
//  Created by Diego Espinoza on 13/04/22.
//

import Foundation
import SwiftUI

struct MarketplaceFeedFooterView: View {

    let username: String
    let isRequested: Bool
    let friendLevel: String
    let offerType: OfferType
    let action: () -> Void

    var body: some View {
        HStack {
            ZStack {
                Image(R.image.marketplace.defaultAvatar.name)
                    .resizable()
                    .frame(size: Appearance.GridGuide.feedAvatarSize)
                    .cornerRadius(Appearance.GridGuide.buttonCorner)

                if isRequested {
                    Appearance.Colors.gray1
                        .opacity(0.8)
                        .frame(size: Appearance.GridGuide.feedAvatarSize)
                        .cornerRadius(Appearance.GridGuide.buttonCorner)
                }
            }

            VStack(alignment: .leading) {
                Text(offerType == .buy ? L.marketplaceDetailUserBuy(username) : L.marketplaceDetailUserSell(username))
                    .textStyle(.paragraphSmallSemiBold)
                    .foregroundColor(Appearance.Colors.whiteText)

                Text(friendLevel)
                    .textStyle(.micro)
                    .foregroundColor(Appearance.Colors.gray4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                if !isRequested {
                    action()
                }
            } label: {
                if isRequested {
                    requestedLabel
                } else {
                    requestLabel
                }
            }
            .frame(height: Appearance.GridGuide.baseHeight)
            .background(isRequested ? Appearance.Colors.gray1 : Appearance.Colors.yellow100)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }

    private var requestedLabel: some View {
        HStack {
            Image(systemName: "checkmark")
                .resizable()
                .foregroundColor(Appearance.Colors.whiteText)
                .frame(size: Appearance.GridGuide.tinyIconSize)
                .padding(Appearance.GridGuide.tinyPadding)
                .background(Color.blue)
                .clipShape(Circle())

            Text(L.offerRequested())
                .textStyle(.descriptionSemiBold)
                .foregroundColor(Appearance.Colors.whiteText)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }

    private var requestLabel: some View {
        HStack {
            Image(R.image.marketplace.eyeBlack.name)

            Text(L.offerRequest())
                .textStyle(.descriptionSemiBold)
                .foregroundColor(Appearance.Colors.primaryText)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

#if DEBUG || DEVEL
struct MarketplaceFeedFooterViewPreview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MarketplaceFeedFooterView(username: "Murakami",
                                      isRequested: true,
                                      friendLevel: "Friend",
                                      offerType: .buy,
                                      action: {})
                .previewDevice("iPhone 11")
            MarketplaceFeedFooterView(username: "Murakami",
                                      isRequested: false,
                                      friendLevel: "Friend of Friend",
                                      offerType: .sell,
                                      action: {})
                .previewDevice("iPhone 11")
            MarketplaceFeedFooterView(username: "Murakami",
                                      isRequested: true,
                                      friendLevel: "Friend",
                                      offerType: .buy,
                                      action: {})
                .previewDevice("iPhone 11")
            MarketplaceFeedFooterView(username: "Murakami",
                                      isRequested: false,
                                      friendLevel: "Friend of Friend",
                                      offerType: .sell,
                                      action: {})
                .previewDevice("iPhone 11")
        }
        .padding()
        .background(Color.black)
    }
}
#endif
