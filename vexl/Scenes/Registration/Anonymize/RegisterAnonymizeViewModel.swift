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

struct AnonymizeInput: Equatable {
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
        anonymizedUsername ?? input.username
    }

    var avatar: Data? {
        input.avatar
    }

    var anonymizedAvatar: String {
        return anonymizedAvatars[anonymizedAvatarIndex]
    }

    var identityText: String {
        switch currentState {
        case .identity:
            return L.anonymizeUserTitle()
        case .anonymized:
            return L.anonymizeUserTitle2()
        }
    }

    var subtitle: String {
        switch currentState {
        case .identity:
            return L.anonymizeUserNote()
        case .anonymized:
            return L.anonymizeUserNote2()
        }
    }

    var buttonTitle: String {
        switch currentState {
        case .identity:
            return L.anonymizeUserBtn()
        case .anonymized:
            return L.continue()
        }
    }

    var showSubtitleIcon: Bool {
        currentState == .identity
    }

    @Published var currentState: State = .identity

    @Published var loading = false
    @Published var error: Error?
    @Published var showAnimationOverlay = false
    @Published var anonymizedUsername: String?
    static let animationDuration: CGFloat = 1.5

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
    private var anonymizedAvatarIndex = 0
    private let anonymizedAvatars = [R.image.avatars.defaultAvatar1.name,
                                     R.image.avatars.defaultAvatar2.name,
                                     R.image.avatars.defaultAvatar3.name]

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
            .withUnretained(self)
            .filter { owner, action in
                action == .anonymize && !owner.showAnimationOverlay
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.showAnimationOverlay = true

                after(Self.animationDuration) {
                    owner.showAnimationOverlay = false
                }

                after(Self.animationDuration / 2) {
                    if owner.currentState == .identity {
                        owner.currentState = .anonymized
                    }
                    owner.anonymizedUsername = ManagedProfile.generateRandomName()
                    owner.anonymizedAvatarIndex = Int.random(in: 0..<owner.anonymizedAvatars.count)
                }
            }
            .store(in: cancelBag)
    }

    private func setupCreateUserBindings() {
        action
            .filter { $0 == .createUser }
            .asVoid()
            .flatMapLatest(with: self) { owner, _ in
                owner.userRepository
                    .update(
                        username: owner.input.username,
                        avatar: owner.input.avatar,
                        avatarURL: nil,
                        anonymizedUsername: owner.anonymizedUsername ?? ""
                    )
                    .track(activity: owner.primaryActivity)
                    .receive(on: RunLoop.main)
            }
            .map { _ in Route.continueTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
