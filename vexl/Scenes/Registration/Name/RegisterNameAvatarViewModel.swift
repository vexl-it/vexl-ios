//
//  RegisterNameAvatarViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

final class RegisterNameAvatarViewModel: ViewModelType {

    // MARK: - View State

    enum State {
        case usernameInput
        case avatarInput

        var next: State {
            switch self {
            case .usernameInput:
                return .avatarInput
            case .avatarInput:
                return .avatarInput
            }
        }
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case nextTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var username = ""
    @Published var currentState: State = .usernameInput
    @Published var isActionEnabled = false

    var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    private let cancelBag: CancelBag = .init()

    init() {
        setupBinding()
    }

    private func setupBinding() {
        $username
            .withUnretained(self)
            .map { $0.validateUsername($1) }
            .assign(to: &$isActionEnabled)

        $currentState
            .withUnretained(self)
            .sink { owner, state in
                switch state {
                case .usernameInput:
                    owner.isActionEnabled = owner.validateUsername(owner.username)
                case .avatarInput:
                    owner.isActionEnabled = false
                }
            }
            .store(in: cancelBag)

        action
            .withUnretained(self)
            .sink { owner, action in
                switch action {
                case .nextTap:
                    switch owner.currentState {
                    case .usernameInput:
                        owner.currentState = owner.currentState.next
                    case .avatarInput:
                        owner.route.send(.continueTapped)
                    }
                }
            }
            .store(in: cancelBag)
    }

    private func validateUsername(_ username: String) -> Bool {
        !username.isEmpty
    }
}
