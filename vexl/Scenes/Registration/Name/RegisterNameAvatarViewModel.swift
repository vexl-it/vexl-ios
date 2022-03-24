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

    @Inject var userService: UserServiceType

    // MARK: - View State

    enum State {
        case phoneVerified
        case usernameInput
        case avatarInput
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case nextTap
        case setUsername
        case createUser
        case addAvatar
        case deleteAvatar
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var username = ""
    @Published var currentState: State = .phoneVerified
    @Published var avatar: UIImage?
    @Published var isActionEnabled = false

    @Published var loading = false

    var primaryActivity: Activity = .init()
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    private let cancelBag: CancelBag = .init()

    init() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        setupStateBinding()
        setupActionBindings()
    }

    private func setupStateBinding() {
        $username
            .withUnretained(self)
            .filter { $0.0.currentState == .usernameInput }
            .map { $0.validateUsername($1) }
            .assign(to: &$isActionEnabled)

        $currentState
            .withUnretained(self)
            .sink { owner, state in
                switch state {
                case .phoneVerified:
                    after(1) {
                        owner.currentState = .usernameInput
                    }
                case .usernameInput:
                    owner.isActionEnabled = owner.validateUsername(owner.username)
                case .avatarInput:
                    owner.isActionEnabled = true
                }
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {

        action
            .useAction(action: .createUser)
            .withUnretained(self)
            .flatMap { owner, _ in
                owner
                    .userService
                    .createUser(username: owner.username,
                                avatar: "")
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap { $0.value }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.continueTapped)
                owner.currentState = .usernameInput
                owner.username = ""
                owner.avatar = nil
            }
            .store(in: cancelBag)

        action
            .useAction(action: .setUsername)
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .avatarInput
            }
            .store(in: cancelBag)

        action
            .useAction(action: .deleteAvatar)
            .withUnretained(self)
            .sink { owner, _ in
                owner.avatar = nil
            }
            .store(in: cancelBag)

        action
            .useAction(action: .addAvatar)
            .withUnretained(self)
            .sink { owner, _ in
                owner.avatar = UIImage(named: R.image.onboarding.testAvatar.name)
            }
            .store(in: cancelBag)
    }

    private func validateUsername(_ username: String) -> Bool {
        !username.isEmpty
    }
}
