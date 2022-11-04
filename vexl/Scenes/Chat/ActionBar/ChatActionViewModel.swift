//
//  ChatActionViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/07/22.
//

import Foundation
import Cleevio

final class ChatActionViewModel: ObservableObject {

    @Fetched(fetchImmediately: false)
    var fetchedMessages: [ManagedMessage]

    @Published var showIdentityRequest = true
    @Published var isChatBlocked = false
    @Published var isOfferDeleted = false

    var action: ActionSubject<ChatActionView.ChatActionOption> = .init()
    var route: CoordinatingSubject<ChatViewModel.Route> = .init()

    private let cancelBag: CancelBag = .init()
    var offer: ManagedOffer?

    init(chat: ManagedChat) {
        $fetchedMessages.load(predicate: NSPredicate(format: """
            chat == %@
            AND (
                typeRawType == '\(MessageType.revealApproval.rawValue)'
                OR typeRawType == '\(MessageType.revealRejected.rawValue)'
                OR typeRawType == '\(MessageType.revealRequest.rawValue)'
            )
        """, chat))

        $fetchedMessages.publisher
            .map(\.objects.first?.chat)
            .map { chat -> Bool in
                guard let showIdentityRequest = chat?.showIdentityRequest else { return true }
                return showIdentityRequest
            }
            .assign(to: &$showIdentityRequest)

        self.offer = chat.receiverKeyPair?.offer
        self.isChatBlocked = chat.isBlocked

        self.offer?
            .publisher(for: \.isRemoved)
            .assign(to: &$isOfferDeleted)
        setupActionBindings()
    }

    func title(for action: ChatActionOption) -> String {
        switch action {
        case .revealIdentity:
            return L.chatMessageRevealIdentity()
        case .showOffer:
            return offer?.user != nil ? L.chatMessageOfferMy() : L.chatMessageOfferTheirs()
        case .commonFriends:
            return L.chatMessageCommonFriend()
        case .deleteChat:
            return L.chatMessageDeleteChat()
        case .blockUser:
            return L.chatMessageBlockUser()
        }
    }

    private func setupActionBindings() {
        let sharedAction = action
            .share()

        sharedAction
            .filter { $0 == .commonFriends }
            .map { _ -> ChatViewModel.Route in .showCommonFriendsTapped }
            .subscribe(route)
            .store(in: cancelBag)

        sharedAction
            .filter { $0 == .revealIdentity }
            .map { _ -> ChatViewModel.Route in .showRevealIdentityTapped }
            .subscribe(route)
            .store(in: cancelBag)

        sharedAction
            .filter { $0 == .deleteChat }
            .map { _ -> ChatViewModel.Route in .showDeleteTapped }
            .subscribe(route)
            .store(in: cancelBag)

        sharedAction
            .filter { $0 == .showOffer }
            .withUnretained(self)
            .compactMap { owner, _ in owner.offer }
            .map(ChatViewModel.Route.showOfferTapped(offer: ))
            .subscribe(route)
            .store(in: cancelBag)

        sharedAction
            .withUnretained(self)
            .filter { owner, action -> Bool in
                action == .blockUser && !owner.isChatBlocked
            }
            .map { _ -> ChatViewModel.Route in .showBlockTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
