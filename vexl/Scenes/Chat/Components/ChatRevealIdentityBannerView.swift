//
//  ChatRevealIdentityResponseBannerView.swift
//  vexl
//
//  Created by Diego Espinoza on 22/08/22.
//

import SwiftUI

struct ChatRevealIdentityBannerView: View {

    let isRequest: Bool
    let hideAction: (() -> Void)?
    let revealAction: (() -> Void)?

    private var title: String {
        isRequest ? L.chatMessageIdentityRevealRequestSent() : L.chatMessageIdentityRevealRequest()
    }

    private var subtitle: String {
        isRequest ? L.chatMessageIdentityRevealPending() : L.chatMessageIdentityRevealPendingTap()
    }

    var body: some View {
        HStack {
            Image(R.image.marketplace.defaultAvatar.name)

            VStack(alignment: .leading) {
                Text(title)
                    .textStyle(.paragraphSmallSemiBold)

                Text(subtitle)
                    .textStyle(.description)
                    .foregroundColor(Appearance.Colors.gray3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isRequest {
                requestActionButton
            } else {
                responseActionButton
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Appearance.Colors.whiteText)
    }

    private var requestActionButton: some View {
        Button {
            hideAction?()
        } label: {
            Text(L.chatMessageIdentityRevealPendingOk())
                .textStyle(.paragraphSmall)
                .foregroundColor(Appearance.Colors.gray2)
                .padding(Appearance.GridGuide.point)
                .background(Appearance.Colors.gray6)
                .cornerRadius(Appearance.GridGuide.point)
        }
    }

    private var responseActionButton: some View {
        Button {
            revealAction?()
        } label: {
            Image(systemName: "chevron.right")
                .foregroundColor(Appearance.Colors.primaryText)
        }
        .padding(Appearance.GridGuide.point)
        .background(Appearance.Colors.yellow100)
        .cornerRadius(Appearance.GridGuide.point)
    }
}
