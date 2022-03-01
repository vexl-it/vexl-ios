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
        case phoneVerified
        case usernameInput
        case avatarInput

        var next: State {
            switch self {
            case .phoneVerified:
                return .usernameInput
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
        case addAvatar
        case deleteAvatar
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var username = ""
    @Published var currentState: State = .phoneVerified
    @Published var avatar: UIImage?
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
                case .phoneVerified:
                    after(2) {
                        owner.currentState = owner.currentState.next
                    }
                case .usernameInput:
                    owner.isActionEnabled = owner.validateUsername(owner.username)
                case .avatarInput:
                    owner.isActionEnabled = false
                }
            }
            .store(in: cancelBag)

        $avatar
            .withUnretained(self)
            .sink { owner, image in
                owner.isActionEnabled = image != nil
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
                    case .phoneVerified:
                        break
                    }
                case .addAvatar:
                    // TODO: implemente ImagePicker
                    owner.avatar = UIImage(named: R.image.onboarding.testAvatar.name)
                case .deleteAvatar:
                    owner.avatar = nil
                }
            }
            .store(in: cancelBag)
    }

    private func validateUsername(_ username: String) -> Bool {
        !username.isEmpty
    }
}
