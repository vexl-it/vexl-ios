//
//  EditProfileAvatarViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 17/07/22.
//

import Foundation
import Cleevio
import Combine

final class EditProfileAvatarViewModel: ViewModelType, ObservableObject {

    @Inject var userService: UserServiceType
    @Inject var authenticationManager: AuthenticationManagerType
    @Inject var userRepository: UserRepositoryType

    enum ImageSource {
        case photoAlbum, camera
    }

    enum UserAction: Equatable {
        case dismissTap
        case avatarTap
        case updateAvatar
        case cancel
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showImagePicker = false
    @Published var showImagePickerActionSheet = false
    @Published var isAvatarUpdated = false
    @Published var avatar: Data?

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

    var imageSource = ImageSource.photoAlbum
    private let cancelBag: CancelBag = .init()

    init() {
        self.avatar = userRepository.user?.profile?.avatar
        setupActivityBindings()
        setupActionBindings()
    }

    private func setupActivityBindings() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupActionBindings() {
        let action = action.share()

        action
            .filter { $0 == .avatarTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.showImagePickerActionSheet = true
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissTap || $0 == .cancel }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .updateAvatar }
            .asVoid()
            .withUnretained(self)
            .flatMap { owner, avatar in
                owner.userRepository
                    .update(avatar: owner.avatar?.compressImage(quality: 0.25))
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
