//
//  ChatRequestViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import Foundation
import Cleevio

final class ChatRequestViewModel: ViewModelType, ObservableObject {

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    var offerRequests: [ChatRequestOfferViewData] = [
        .init(contactName: "Murakami",
              contactFriendLevel: "Friend",
              requestText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
              friends: [.init(name: "Keichi", image: nil), .init(name: "Satoshi", image: nil), .init(name: "Saito", image: nil)],
              offer: .stub),
        .init(contactName: "Keichi",
              contactFriendLevel: "Friend of Friend",
              requestText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
              friends: [.init(name: "Murakami", image: nil), .init(name: "Satoshi", image: nil), .init(name: "Saito", image: nil)],
              offer: .stub)
    ]

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        setupActionBindings()
    }

    private func setupActionBindings() {
        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
