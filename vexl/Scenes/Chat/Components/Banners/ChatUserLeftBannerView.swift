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
        .background(Appearance.Colors.whiteText)
    }

    private var deleteActionButton: some View {
        Button {
            deleteAction?()
        } label: {
            Text(L.chatDeleteButton())
                .textStyle(.paragraphSmall)
                .foregroundColor(Appearance.Colors.gray2)
                .padding(Appearance.GridGuide.point)
                .background(Appearance.Colors.gray6)
                .cornerRadius(Appearance.GridGuide.point)
        }
    }
}
