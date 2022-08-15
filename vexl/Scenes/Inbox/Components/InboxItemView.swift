//
//  ChatItemView.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import SwiftUI

typealias InboxItem = InboxItemView.ViewModel

struct InboxItemView: View {

    @ObservedObject var data: ViewModel

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

            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    UserOfferTypeAttributedText(username: data.username, offerType: data.offerType)

                    Text(data.time)
                        .foregroundColor(Appearance.Colors.gray3)
                        .textStyle(.micro)
                }

                if !data.detail.isEmpty {
                    HStack(spacing: Appearance.GridGuide.tinyPadding) {
                        if let icon = data.detailIcon {
                            Image(icon)
                        }
                        Text(data.detail)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(data.detailColor)
                            .textStyle(data.detailTextStyle)
                    }
                }
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .leading)
        }
        .padding(.horizontal, Appearance.GridGuide.padding)
    }
}

extension InboxItemView {

    final class ViewModel: Identifiable, Hashable, ObservableObject {
        let chat: ManagedChat

        @Published private var lastMessage: ManagedMessage?

        var id: String { chat.id ?? UUID().uuidString }
        var avatar: Data? { chat.receiverKeyPair?.profile?.avatar }
        var username: String { chat.receiverKeyPair?.profile?.name ?? L.generalAnonymous() }
        var time: String { lastMessage?.formatedDate ?? "" }
        var offerType: OfferType? { chat.receiverKeyPair?.offer?.type }

        var detail: String {
            guard let message = lastMessage else { return "" }
            switch message.type {
            case .message:
                return "\(message.isContact ? "\(L.chatMessageMe()) " : "")\(message.text ?? "")"
            case .revealRequest:
                return message.isContact ? L.chatRequestIdentityContact(username) : L.chatRequestIdentityUser()
            default:
                return ""
            }
        }
        var detailIcon: String? {
            guard let message = lastMessage else { return nil }
            switch message.type {
            case .revealRequest:
                return R.image.onboarding.eye.name
            default:
                return nil
            }
        }
        var detailColor: Color {
            guard let message = lastMessage else { return Appearance.Colors.gray4 }
            switch message.type {
            case .revealRequest:
                return Appearance.Colors.whiteText
            default:
                return Appearance.Colors.gray4
            }
        }
        var detailTextStyle: Appearance.TextStyle {
            guard let message = lastMessage else { return .paragraphSmall }
            switch message.type {
            case .revealRequest:
                return .paragraphSmallBold
            default:
                return .paragraphSmall
            }
        }

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

        static func == (lhs: InboxItemView.ViewModel, rhs: InboxItemView.ViewModel) -> Bool {
            lhs.id == rhs.id
        }
    }
}
