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

    @Published var userIsRevealed = false
    @Published var isChatBlocked = false

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
            .map(\.objects.isEmpty.not)
            .assign(to: &$userIsRevealed)

        self.offer = chat.receiverKeyPair?.offer
        self.isChatBlocked = chat.isBlocked
        setupActionBindings()
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
