//
//  InboxViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio

final class InboxViewModel: ViewModelType, ObservableObject {

    @Inject var inboxManager: InboxManagerType

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
        case messageTapped(id: String)
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
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, messages in
                owner.inboxItems = messages.map { message -> InboxItem in
                    InboxItem(avatar: nil,
                              username: Constants.randomName + "inbox: \(message.inboxKey) sender: \(message.senderInboxKey)",
                              detail: message.previewText,
                              time: Formatters.chatDateFormatter.string(from: Date(timeIntervalSince1970: message.time)),
                              offerType: .buy)
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
            .map { id -> Route in .messageTapped(id: id) }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
