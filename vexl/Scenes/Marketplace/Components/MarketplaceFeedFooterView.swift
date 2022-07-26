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
    var avatar: Data?
    let action: () -> Void

    private var title: String {
        offerType == .buy ? L.marketplaceDetailUserBuy(username) : L.marketplaceDetailUserSell(username)
    }

    var body: some View {
        HStack {
            ContactAvatarInfo(
                isAvatarWithOpacity: isRequested,
                title: title,
                subtitle: friendLevel,
                avatar: avatar
            )

            Button(action: action) {
                if isRequested {
                    requestedLabel
                } else {
                    requestLabel
                }
            }
            .frame(height: Appearance.GridGuide.baseHeight)
            .background(isRequested ? Appearance.Colors.gray1 : Appearance.Colors.yellow100)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
            .disabled(isRequested)
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
