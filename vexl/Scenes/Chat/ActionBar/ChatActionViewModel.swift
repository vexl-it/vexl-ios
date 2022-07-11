//
//  ChatActionViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/07/22.
//

import Foundation
import Cleevio

final class ChatActionViewModel {

    @Published var userIsRevealed = false

    var action: ActionSubject<ChatActionView.ChatActionOption> = .init()
    var route: CoordinatingSubject<ChatViewModel.Route> = .init()

    private let cancelBag: CancelBag = .init()
    var offer: Offer?

    init() {
        setupActionBindings()
    }

    private func setupActionBindings() {
        let sharedAction = action
            .share()

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
            .withUnretained(self)
            .filter { owner, action in
                action == .showOffer && owner.offer != nil
            }
            .map { owner, _ -> ChatViewModel.Route in .showOfferTapped(offer: owner.offer) }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
