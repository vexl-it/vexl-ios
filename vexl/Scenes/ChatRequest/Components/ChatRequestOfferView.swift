//
//  ChatRequestOfferView.swift
//  vexl
//
//  Created by Diego Espinoza on 27/05/22.
//

import SwiftUI
import Cleevio

typealias ChatRequestOfferViewData = ChatRequestOfferView.ViewModel

struct ChatRequestOfferView: View {

    @ObservedObject var data: ChatRequestOfferViewData
    let accept: (ManagedChat) -> Void
    let decline: (ManagedChat) -> Void

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
                decline(data.chat)
            })
                .foregroundColor(Appearance.Colors.yellow100)

            actionButton(title: L.chatRequestAccept(),
                         backgroundColor: Appearance.Colors.yellow100,
                         action: {
                accept(data.chat)
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

    class ViewModel: Identifiable, Hashable, ObservableObject {
        @Inject var contactRepository: ContactsRepositoryType

        @Published var friends: [ChatRequestFriendViewData] = []

        var chat: ManagedChat

        let id: String
        let contactName: String
        let contactFriendLevel: String
        let requestText: String
        let offer: OfferDetailViewData

        private let cancelBag: CancelBag = .init()

        init?(chat: ManagedChat) {
            guard let offer = chat.receiverKeyPair?.offer else {
                return nil
            }
            self.chat = chat
            id = chat.id ?? UUID().uuidString
            contactName = chat.receiverKeyPair?.profile?.name ?? L.generalAnonymous()
            contactFriendLevel = chat.receiverKeyPair?.offer?.friendLevel?.label ?? ""
            let messages: Set<ManagedMessage>? = chat.messages as? Set<ManagedMessage>
            requestText = messages?.first(where: { $0.type == .messagingRequest })?.text ?? ""
            self.offer = .init(offer: offer)

            self.contactRepository
                .getContacts(hashes: offer.commonFriends ?? [])
                .map { contacts in
                    contacts.map { contact in
                        ChatRequestFriendViewData(name: contact.name ?? "", image: contact.avatar)
                    }
                }
                .sink()
                .store(in: cancelBag)
        }

        static func == (lhs: ChatRequestOfferView.ViewModel, rhs: ChatRequestOfferView.ViewModel) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
