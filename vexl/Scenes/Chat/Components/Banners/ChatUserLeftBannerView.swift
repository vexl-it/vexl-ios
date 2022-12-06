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

            VStack(alignment: .leading) {
                Text(L.chatDeleteTitle(username))
                    .textStyle(.paragraphSmallSemiBold)

                Text(L.chatDeleteSubtitle())
                    .textStyle(.description)
                    .foregroundColor(Appearance.Colors.gray3)
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
                .padding(Appearance.GridGuide.point)
                .background(Appearance.Colors.yellow100)
                .cornerRadius(Appearance.GridGuide.point)
        }
    }
}
