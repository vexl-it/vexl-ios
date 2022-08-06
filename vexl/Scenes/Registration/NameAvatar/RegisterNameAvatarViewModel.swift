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
    @Inject var userRepository: UserRepositoryType

    enum ImageSource {
        case photoAlbum, camera
    }

    // MARK: - View State

    enum State {
        case startRegistration
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
    @Published var currentState: State = .startRegistration
    @Published var avatar: Data?
    @Published var isActionEnabled = false
    @Published var showImagePicker = false
    @Published var showImagePickerActionSheet = false

    @Published var loading = false
    @Published var error: Error?

    var primaryActivity: Activity = .init()
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var avatarButtonTitle: String {
        avatar == nil ? L.continue() : L.generalSave()
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    private let cancelBag: CancelBag = .init()
    var imageSource = ImageSource.photoAlbum

    init() {
        setupActivity()
        setupStateBinding()
        setupActionBindings()
        setupCreateUserBindings()
    }

    func updateToPreviousState() {
        switch currentState {
        case .avatarInput:
            clearState()
            currentState = .usernameInput
        case .startRegistration, .usernameInput:
            break
        }
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

    private func setupStateBinding() {
        $username
            .withUnretained(self)
            .filter { $0.0.currentState == .usernameInput }
            .map { $0.validateUsername($1) }
            .assign(to: &$isActionEnabled)

        $currentState
            .filter { $0 == .startRegistration }
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .usernameInput
            }
            .store(in: cancelBag)

        $currentState
            .filter { $0 == .usernameInput }
            .withUnretained(self)
            .sink { owner, _ in
                owner.isActionEnabled = owner.validateUsername(owner.username)
            }
            .store(in: cancelBag)

        $currentState
            .filter { $0 == .avatarInput }
            .withUnretained(self)
            .sink { owner, _ in
                owner.isActionEnabled = true
            }
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        action
            .filter { $0 == .setUsername }
            .map { _ in State.avatarInput }
            .assign(to: &$currentState)

        action
            .filter { $0 == .deleteAvatar }
            .withUnretained(self)
            .sink { owner, _ in
                owner.avatar = nil
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .addAvatar }
            .withUnretained(self)
            .sink { owner, _ in
                owner.showImagePickerActionSheet = true
            }
            .store(in: cancelBag)
    }

    private func setupCreateUserBindings() {
        action
            .filter { $0 == .createUser }
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<String?, Never> in
                guard let avatar = owner.avatar else { return Just<String?>(nil).eraseToAnyPublisher() }
                return avatar.base64Publisher
                    .track(activity: owner.primaryActivity)
            }
            .flatMapLatest(with: self) { owner, base64 -> AnyPublisher<(User, String?), Never> in
                owner.userService
                    .createUser(username: owner.username,
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
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.continueTapped)
                owner.currentState = .usernameInput
                owner.username = ""
                owner.avatar = nil
            }
            .store(in: cancelBag)
    }

    private func validateUsername(_ username: String) -> Bool {
        !username.isEmpty
    }

    private func clearState() {
        username = ""
        avatar = nil
    }
}