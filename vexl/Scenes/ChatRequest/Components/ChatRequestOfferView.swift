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

            ChatRequestFriendsView(data: data.friends)
                .padding(.horizontal, Appearance.GridGuide.point)
                .padding(.top, Appearance.GridGuide.padding)

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
            Button(L.chatRequestDecline(), action: {
                print("Declined")
            })
                .textStyle(.titleSmallSemiBold)
                .foregroundColor(Appearance.Colors.yellow100)
                .frame(height: Appearance.GridGuide.largeButtonHeight)
                .frame(maxWidth: .infinity)
                .background(Appearance.Colors.yellow20)
                .cornerRadius(Appearance.GridGuide.buttonCorner)

            Button(L.chatRequestAccept(), action: {
                print("Accept")
            })
                .textStyle(.titleSmallSemiBold)
                .foregroundColor(Appearance.Colors.primaryText)
                .frame(height: Appearance.GridGuide.largeButtonHeight)
                .frame(maxWidth: .infinity)
                .background(Appearance.Colors.yellow100)
                .cornerRadius(Appearance.GridGuide.buttonCorner)
        }
        .padding(.top, Appearance.GridGuide.largePadding2)
    }
}

extension ChatRequestOfferView {

    struct ViewData: Identifiable, Hashable {
        let id = UUID()
        let contactName: String
        let contactFriendLevel: String
        let requestText: String
        let friends: [ChatRequestFriendViewData]
        let offer: OfferDetailViewData
    }
}
