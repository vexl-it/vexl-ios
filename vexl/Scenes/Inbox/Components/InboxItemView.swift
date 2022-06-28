//
//  ChatItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import SwiftUI

typealias InboxItem = InboxItemView.ViewData

struct InboxItemView: View {

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
            ContactAvatarView(image: data.avatar,
                              size: Appearance.GridGuide.mediumIconSize)

            VStack(alignment: .leading) {
                HStack(spacing: .zero) {
                    Text(data.username)
                        .foregroundColor(Appearance.Colors.whiteText)
                        .textStyle(.paragraphSmallBold)

                    // TODO: - add offer type here

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
}

extension InboxItemView {
    struct ViewData: Identifiable, Hashable {
        let id = UUID()
        let avatar: UIImage?
        let username: String
        let detail: String
        let time: String
        let offerType: OfferType
    }
}
