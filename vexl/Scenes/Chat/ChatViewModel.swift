//
//  ChatViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio

final class ChatViewModel: ViewModelType, ObservableObject {

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case selectFilter(option: ChatFilterOption)
        case continueTap
        case requestTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var filter: ChatFilterOption = .all
    @Published var primaryActivity: Activity = .init()

    @Published var chatItems: [ChatItem] = [
        .init(avatar: nil, username: "Keichi", detail: "qwerty", time: "Yesterday", offerType: .buy),
        .init(avatar: nil, username: "Keichi", detail: "qwerty", time: "Yesterday", offerType: .buy),
        .init(avatar: nil, username: "Keichi", detail: "qwerty", time: "Yesterday", offerType: .sell)
    ]

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case requestTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let bitcoinViewModel: BitcoinViewModel
    private let cancelBag: CancelBag = .init()

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        setupActionBindings()
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
            .compactMap { action -> ChatFilterOption? in
                if case let .selectFilter(option) = action { return option }
                return nil
            }
            .assign(to: &$filter)
    }
}
