//
//  ChatRequestFriendsView.swift
//  vexl
//
//  Created by Diego Espinoza on 27/05/22.
//

import SwiftUI

typealias ChatRequestFriendViewData = ChatRequestFriendsView.ViewData

struct ChatRequestFriendsView: View {

    let data: [ViewData]

    var body: some View {
        HStack {
            if data.isEmpty {
                HStack(alignment: .center, spacing: Appearance.GridGuide.point) {
                    Group {
                        Image(R.image.offer.infoGray.name)
                        Text(L.requestCommonFriendsEmptyState())
                            .textStyle(.descriptionSemiBold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Appearance.Colors.gray3)
                    }
                }
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(data) { friendData in
                            friendItem(friendData)
                        }
                    }
                    .padding()
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(Appearance.Colors.gray3)
                    .padding(.vertical, Appearance.GridGuide.padding)
                    .padding(.horizontal, Appearance.GridGuide.point)
            }
        }
        .background(Appearance.Colors.gray6)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    @ViewBuilder private func friendItem(_ data: ViewData) -> some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            ContactAvatarView(image: data.image,
                              size: Appearance.GridGuide.iconSize)

            Text(data.name)
                .foregroundColor(Appearance.Colors.primaryText)
                .textStyle(Appearance.TextStyle.paragraphSmallMedium)
        }
    }
}

extension ChatRequestFriendsView {

    struct ViewData: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let image: Data?
    }
}
