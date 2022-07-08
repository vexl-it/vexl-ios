//
//  ChatIdentityRevealViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 7/07/22.
//

import Foundation
import Cleevio

final class ChatIdentityRevealViewModel: ViewModelType, ObservableObject {

    enum UserAction: Equatable {
        case dismissTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()
    let isUserResponse: Bool
    let username: String
    let avatar: String?

    var avatarData: Data? {
        avatar?.dataFromBase64
    }

    init(isUserResponse: Bool, username: String, avatar: String?) {
        self.isUserResponse = isUserResponse
        self.username = username
        self.avatar = avatar
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
