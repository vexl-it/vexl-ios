//
//  ChatUserLeftBannerView.swift
//  vexl
//
//  Created by Adam Salih on 02.12.2022.
//

import SwiftUI

struct ChatUserLeftBannerView: View {

    var username: String
    var avatar: Data?
    let deleteAction: (() -> Void)?

    var body: some View {
        HStack {
            Image(data: avatar, placeholder: R.image.marketplace.defaultAvatar.name)
                .resizable()
                .frame(size: Appearance.GridGuide.chatAvatarSize)
                .cornerRadius(Appearance.GridGuide.groupLabelCorner)

            VStack(alignment: .leading) {
                Text(username)
                    .textStyle(.description)
                    .foregroundColor(Appearance.Colors.gray3)

                Text(L.chatDeleteSubtitle())
                    .textStyle(.paragraphSmallSemiBold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            deleteActionButton
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Appearance.GridGuide.chatBannerHeight)
        .background(Appearance.Colors.whiteText)
    }

    private var deleteActionButton: some View {
        Button {
            deleteAction?()
        } label: {
            Text(L.chatDeleteButton())
                .textStyle(.descriptionBold)
                .foregroundColor(Appearance.Colors.primaryText)
                .padding(.vertical, Appearance.GridGuide.padding)
                .padding(.horizontal, Appearance.GridGuide.mediumPadding1)
                .background(Appearance.Colors.yellow100)
                .cornerRadius(Appearance.GridGuide.point)
        }
    }
}
