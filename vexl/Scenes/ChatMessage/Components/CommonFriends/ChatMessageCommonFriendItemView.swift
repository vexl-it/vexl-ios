//
//  ChatMessageCommonFriendItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 1/06/22.
//

import SwiftUI

struct ChatMessageCommonFriendItemView: View {

    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Image(R.image.marketplace.defaultAvatar.name)
                .resizable()
                .frame(size: Appearance.GridGuide.mediumIconSize)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

            VStack(alignment: .leading) {
                Text(title)
                    .textStyle(.paragraphMedium)
                    .foregroundColor(Appearance.Colors.primaryText)

                Text(subtitle)
                    .textStyle(.description)
                    .foregroundColor(Appearance.Colors.gray3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
