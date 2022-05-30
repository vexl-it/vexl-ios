//
//  ChatItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import SwiftUI

typealias ChatItem = ChatItemView.ViewData

struct ChatItemView: View {

    struct ViewData: Identifiable, Hashable {
        let id = UUID()
        let avatar: UIImage?
        let username: String
        let detail: String
        let time: String
        let offerType: OfferType
    }

    var data: ViewData

    private var offerLabel: String {
        switch data.offerType {
        case .buy:
            return L.marketplaceDetailUserBuy("")
        case .sell:
            return L.marketplaceDetailUserSell("")
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            userAvatar

            VStack(alignment: .leading) {
                HStack(spacing: .zero) {
                    Text(data.username)
                        .foregroundColor(Appearance.Colors.whiteText)
                        .textStyle(.paragraphSmallBold)

                    Text(offerLabel)
                        .foregroundColor(data.offerType == .buy ? Appearance.Colors.green100 : Appearance.Colors.pink100)
                        .textStyle(.paragraphSmallBold)
                }

                Text(data.detail)
                    .foregroundColor(Appearance.Colors.gray4)
                    .textStyle(.paragraphSmall)
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .leading)

            Text(data.time)
                .foregroundColor(Appearance.Colors.gray3)
                .textStyle(.micro)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }

    @ViewBuilder private var userAvatar: some View {
        if let avatar = data.avatar {
            Image(uiImage: avatar)
                .resizable()
                .frame(size: Appearance.GridGuide.mediumIconSize)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        } else {
            Image(R.image.marketplace.defaultAvatar.name)
                .resizable()
                .frame(size: Appearance.GridGuide.mediumIconSize)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
    }
}
