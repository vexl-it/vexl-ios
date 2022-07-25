//
//  ChatItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import SwiftUI

typealias InboxItem = InboxItemView.ViewData

struct InboxItemView: View {

    @ObservedObject var data: ViewData

    private var offerLabel: String {
        guard let offerType = data.offerType else {
            return ""
        }

        switch offerType {
        case .buy:
            return L.marketplaceDetailUserBuy("")
        case .sell:
            return L.marketplaceDetailUserSell("")
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            ContactAvatarView(image: data.avatar,
                              size: Appearance.GridGuide.mediumIconSize)

            VStack(alignment: .leading) {
                HStack(spacing: .zero) {
                    Text(data.username)
                        .foregroundColor(Appearance.Colors.whiteText)
                        .textStyle(.paragraphSmallBold)

                    if let offerType = data.offerType {
                        Text(offerLabel)
                            .textStyle(.paragraphSmallBold)
                            .foregroundColor(offerType == .sell ? Appearance.Colors.pink100 : Appearance.Colors.green100)
                    }
                }

                Text(data.detail)
                    .foregroundColor(Appearance.Colors.gray4)
                    .textStyle(.paragraphSmall)
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .leading)

            Text(data.time)
                .foregroundColor(Appearance.Colors.gray3)
                .textStyle(.micro)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

extension InboxItemView {

    final class ViewData: Identifiable, Hashable, ObservableObject {
        static func == (lhs: InboxItemView.ViewData, rhs: InboxItemView.ViewData) -> Bool {
            lhs.id == rhs.id
        }

        let chat: ManagedChat

        @Published private var lastMessage: ManagedMessage?

        var id: String { chat.id ?? UUID().uuidString }
        var avatar: Data? { chat.receiverKeyPair?.profile?.avatar }
        var username: String { chat.receiverKeyPair?.profile?.name ?? Constants.randomName }
        var detail: String { lastMessage?.text ?? "" }
        var time: String { lastMessage?.formatedDate ?? "" }
        var offerType: OfferType? { chat.receiverKeyPair?.offer?.type }

        init(chat: ManagedChat) {
            self.chat = chat

            chat
                .publisher(for: \.messages)
                .map { messages in
                    messages?
                        .sortedArray(
                            using: [ NSSortDescriptor(key: "time", ascending: true) ]
                        ).last as? ManagedMessage
                }
                .assign(to: &$lastMessage)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
