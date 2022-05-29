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
        case selectMessage(id: String)
        case requestTap
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var filter: ChatFilterOption = .all
    @Published var primaryActivity: Activity = .init()

    @Published var chatItems: [ChatItem] = [
        .init(avatar: nil, username: "Keichi", detail: "Hello there", time: "Yesterday", offerType: .buy)
    ]

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case requestTapped
        case messageTapped(id: String)
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

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
            .withUnretained(self)
            .sink { owner, option in
                owner.filter = option
            }
            .store(in: cancelBag)

        action
            .print("???!!")
            .compactMap { action -> String? in
                if case let .selectMessage(id) = action { return id }
                return nil
            }
            .withUnretained(self)
            .sink { owner, id in
                owner.route.send(.messageTapped(id: id))
            }
            .store(in: cancelBag)
    }
}
