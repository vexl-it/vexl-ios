//
//  ChatRequestOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 27/05/22.
//

import SwiftUI

typealias ChatRequestOfferViewData = ChatRequestOfferView.ViewData

struct ChatRequestOfferView: View {

    let data: ChatRequestOfferViewData
    let accept: (String) -> Void
    let decline: (String) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ScrollView(showsIndicators: false) {
                ContactAvatarInfo(isAvatarWithOpacity: false,
                                  title: data.contactName,
                                  subtitle: data.contactFriendLevel,
                                  style: .large)
                    .padding(.horizontal, Appearance.GridGuide.padding)

                card
            }

            buttons
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text(data.requestText)
                .padding([.horizontal, .top], Appearance.GridGuide.mediumPadding1)
                .textStyle(.titleSmallMedium)

            if !data.friends.isEmpty {
                ChatRequestFriendsView(data: data.friends)
                    .padding(.horizontal, Appearance.GridGuide.point)
                    .padding(.top, Appearance.GridGuide.padding)
            }

            ChatRequestOfferInformationView(data: data.offer)
                .background(Appearance.Colors.gray6)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
                .padding(Appearance.GridGuide.point)
        }
        .background(Appearance.Colors.whiteText)
        .cornerRadius(Appearance.GridGuide.requestCorner)
        .padding(.top, Appearance.GridGuide.mediumPadding1)
    }

    private var buttons: some View {
        HStack {
            actionButton(title: L.chatRequestDecline(),
                         backgroundColor: Appearance.Colors.yellow20,
                         action: {
                decline(data.id)
            })
                .foregroundColor(Appearance.Colors.yellow100)

            actionButton(title: L.chatRequestAccept(),
                         backgroundColor: Appearance.Colors.yellow100,
                         action: {
                accept(data.id)
            })
                .foregroundColor(Appearance.Colors.primaryText)
        }
        .padding(.top, Appearance.GridGuide.largePadding2)
    }

    @ViewBuilder private func actionButton(title: String,
                                           backgroundColor: Color,
                                           action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .textStyle(.titleSmallSemiBold)
            .frame(height: Appearance.GridGuide.largeButtonHeight)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(Appearance.GridGuide.buttonCorner)
    }
}

extension ChatRequestOfferView {

    struct ViewData: Identifiable, Hashable {
        let id = UUID().uuidString
        let contactName: String
        let contactFriendLevel: String
        let requestText: String
        let friends: [ChatRequestFriendViewData]
        let offer: OfferDetailViewData
    }
}
