//
//  RegisterAnonymizeViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 07.08.2022.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

struct AnonymizeInput {
    let username: String
    let avatar: Data?
}

final class RegisterAnonymizeViewModel: ViewModelType {

    @Inject var userService: UserServiceType
    @Inject var userRepository: UserRepositoryType

    // MARK: - View State

    enum State {
        case identity
        case anonymized
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case anonymize
        case createUser
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    var username: String {
        input.username
    }

    var avatar: Data? {
        input.avatar
    }

    var identityText: String {
        switch currentState {
        case .identity:
            return "This is your identity"
        case .anonymized:
            return "Identity anonymized!"
        }
    }

    var subtitle: String {
        switch currentState {
        case .identity:
            return "Nobody will see your identity until you allow it"
        case .anonymized:
            return "This is how other users will see you until you reveal your real identity."
        }
    }

    var buttonTitle: String {
        switch currentState {
        case .identity:
            return "Anonymize"
        case .anonymized:
            return "Continue"
        }
    }

    var showSubtitleIcon: Bool {
        currentState == .identity
    }

    @Published var currentState: State = .identity

    @Published var loading = false
    @Published var error: Error?

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
    private let input: AnonymizeInput

    init(input: AnonymizeInput) {
        self.input = input
        setupActivity()
        setupActionBindings()
        setupCreateUserBindings()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupActionBindings() {
        action
            .filter { $0 == .anonymize }
            .map { _ in State.anonymized }
            .assign(to: &$currentState)
    }

    private func setupCreateUserBindings() {
        action
            .filter { $0 == .createUser }
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<String?, Never> in
                guard let avatar = owner.input.avatar else { return Just<String?>(nil).eraseToAnyPublisher() }
                return avatar.base64Publisher
                    .track(activity: owner.primaryActivity)
            }
            .flatMapLatest(with: self) { owner, base64 -> AnyPublisher<(User, String?), Never> in
                owner.userService
                    .createUser(username: owner.input.username,
                                avatar: base64)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { ($0, base64) }
                    .eraseToAnyPublisher()
            }
            .flatMapLatest(with: self, { owner, user in
                owner.userRepository
                    .update(with: user.0, avatar: user.1?.dataFromBase64)
                    .track(activity: owner.primaryActivity)
                    .receive(on: RunLoop.main)
            })
            .map { _ in Route.continueTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
