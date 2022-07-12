//
//  InboxViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio
import Combine

private typealias OfferKeyAndType = (offerKey: String, offerType: OfferType)
private typealias OfferAndMessage = (offers: [OfferKeyAndType], messages: [ChatInboxMessage])
private typealias OfferMessagesAndUsers = (offers: [OfferKeyAndType], messages: [ChatInboxMessage], users: [StoredChatUser])

final class InboxViewModel: ViewModelType, ObservableObject {

    @Inject var inboxManager: InboxManagerType
    @Inject var offerService: OfferServiceType
    @Inject var chatService: ChatServiceType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case selectFilter(option: InboxFilterOption)
        case continueTap
        case requestTap
        case selectMessage(id: String)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var filter: InboxFilterOption = .all
    @Published var primaryActivity: Activity = .init()

    @Published var inboxItems: [InboxItem] = []

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case requestTapped
        case conversationTapped(inboxKeys: ECCKeys, recieverPublicKey: String, offerType: OfferType?)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let bitcoinViewModel: BitcoinViewModel
    private let cancelBag: CancelBag = .init()

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        setupActionBindings()
        setupInboxBindings()
    }

    private func setupInboxBindings() {
        inboxManager.inboxMessages
            .withUnretained(self)
            .flatMap { owner, chatInboxMessages in
                owner.offerService
                    .getStoredOffers(fromType: .all, fromSource: .all)
                    .materialize()
                    .compactMap(\.value)
                    .map { offers -> OfferAndMessage in
                        let offerKeyAndTypes = offers.map { offer in
                            OfferKeyAndType(offerKey: offer.offerPublicKey, offerType: offer.type)
                        }
                        return OfferAndMessage(offers: offerKeyAndTypes, messages: chatInboxMessages)
                    }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .flatMap { owner, offerAndMessages in
                owner.chatService
                    .getStoredContactIdentities()
                    .materialize()
                    .compactMap(\.value)
                    .map { OfferMessagesAndUsers(offers: offerAndMessages.offers, messages: offerAndMessages.messages, users: $0) }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, offerMessagesAndUsers in
                let chatInboxMessages = offerMessagesAndUsers.messages
                let offerKeyAndTypes = offerMessagesAndUsers.offers
                let users = offerMessagesAndUsers.users

                owner.inboxItems = chatInboxMessages.map { chatInbox -> InboxItem in
                    let offerType = offerKeyAndTypes.first(where: {
                        $0.offerKey == chatInbox.message.inboxKey || $0.offerKey == chatInbox.message.contactInboxKey
                    })?.offerType

                    let user = users.first(where: {
                        $0.inboxPublicKey == chatInbox.message.inboxKey && $0.contactPublicKey == chatInbox.message.contactInboxKey
                    })

                    return InboxItem(avatar: user?.avatar?.dataFromBase64,
                                     username: user?.username ?? Constants.randomName,
                                     detail: chatInbox.message.previewText,
                                     time: Formatters.chatDateFormatter.string(from: Date(timeIntervalSince1970: chatInbox.message.time)),
                                     offerType: offerType)
                }
            })
            .store(in: cancelBag)
    }

    private func setupActionBindings() {

        let action = action
            .share()

        action
            .filter { $0 == .requestTap }
            .map { _ -> Route in .requestTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .compactMap { action -> InboxFilterOption? in
                if case let .selectFilter(option) = action { return option }
                return nil
            }
            .assign(to: &$filter)

        action
            .compactMap { action -> String? in
                if case let .selectMessage(id) = action { return id }
                return nil
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, id in
                guard let index = owner.inboxItems.firstIndex(where: { $0.id.uuidString == id }) else {
                    return
                }
                let chatInboxMessage = owner.inboxManager.currentInboxMessages[index]
                let offerType = owner.inboxItems[index].offerType
                owner.route.send(.conversationTapped(inboxKeys: chatInboxMessage.inbox,
                                                     recieverPublicKey: chatInboxMessage.contactInbox,
                                                     offerType: offerType))
            })
            .store(in: cancelBag)
    }
}
