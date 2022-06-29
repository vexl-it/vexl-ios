//
//  ChatHeaderView.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import SwiftUI

struct ChatHeaderView: View {

    let username: String
    let offerLabel: String
    let avatar: UIImage?
    let offerType: OfferType
    let closeAction: () -> Void

    var body: some View {
        HStack(spacing: .zero) {
            CloseButton {
                closeAction()
            }

            VStack {
                ContactAvatarView(image: avatar,
                                  size: Appearance.GridGuide.chatAvatarSize)

                HStack(spacing: .zero) {
                    Text(username)
                        .foregroundColor(Appearance.Colors.whiteText)

                    // TODO: - add offer type here
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.trailing, Appearance.GridGuide.baseButtonSize.width * 0.5)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}
