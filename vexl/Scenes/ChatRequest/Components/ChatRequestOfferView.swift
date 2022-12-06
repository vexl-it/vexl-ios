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
                                  titleType: .normal(data.contactName),
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
            Text(data.requestText ?? L.offerEmptyMessage(data.contactName))
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
        .cornerRadius(Appearance.GridGuide.requestAvatarCorner)
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

    final class ViewModel: Identifiable, Hashable, ObservableObject {
        @Inject var contactService: ContactsServiceType
        @Inject var contactRepository: ContactsRepositoryType

        @Published var friends: [ChatRequestFriendViewData] = []

        var chat: ManagedChat

        let id: String
        let contactName: String
        let contactFriendLevel: String
        let requestText: String?
        let offer: OfferDetailViewData

        private let cancelBag: CancelBag = .init()

        init?(chat: ManagedChat) {
            guard let keyPair = chat.receiverKeyPair, let pubKey = keyPair.publicKey, let offer = keyPair.offer else {
                return nil
            }
            self.chat = chat
            id = chat.id ?? UUID().uuidString
            contactName = chat.receiverKeyPair?.profile?.name ?? L.generalAnonymous()
            let messages: Set<ManagedMessage>? = chat.messages as? Set<ManagedMessage>
            let message = messages?.first(where: { $0.type == .messagingRequest })?.text
            if message?.isEmpty == false {
                requestText = message
            } else {
                requestText = nil
            }

            self.offer = .init(offer: offer)

            @Inject var profileManager: AnonymousProfileManagerType
            if let publicKey = chat.receiverKeyPair?.publicKey,
               let priorityType = profileManager.getFriendLevels(publicKey: publicKey).priorityProfileType,
               let type = priorityType.asOfferFriendDegree {
                contactFriendLevel = type.label
            } else {
                contactFriendLevel = ""
            }

            contactService
                .getCommonFriends(publicKeys: [pubKey])
                .compactMap { $0[pubKey] }
                .filter(\.isEmpty.not)
                .flatMap { [contactRepository] hashes in
                    contactRepository
                        .getCommonFriends(hashes: hashes)
                }
                .map { contacts in
                    contacts.map { contact in
                        ChatRequestFriendViewData(
                            name: contact.name ?? "",
                            image: contact.avatar
                        )
                    }
                }
                .nilOnError()
                .filterNil()
                .withUnretained(self)
                .sink(receiveValue: { owner, contacts in
                    withAnimation {
                        owner.friends = contacts
                    }
                })
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
