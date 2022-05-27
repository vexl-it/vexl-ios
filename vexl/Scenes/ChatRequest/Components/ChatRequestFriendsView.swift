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
        .background(Appearance.Colors.gray6)
        .cornerRadius(Appearance.GridGuide.buttonCorner)
    }

    @ViewBuilder private func friendItem(_ data: ViewData) -> some View {
        HStack(spacing: Appearance.GridGuide.tinyPadding) {
            Image(R.image.marketplace.defaultAvatar.name)
                .resizable()
                .frame(size: Appearance.GridGuide.iconSize)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

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
        let image: UIImage?
    }
}
