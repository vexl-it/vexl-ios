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

    enum ImageSource {
        case photoAlbum, camera
    }

    enum UserAction: Equatable {
        case dismissTap
        case selectAvatar
        case updateAvatar
        case cancel
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var showImagePicker = false
    @Published var showImagePickerActionSheet = false
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
    var isAvatarUpdated = false
    private let cancelBag: CancelBag = .init()

    init() {
        self.avatar = authenticationManager.currentUser?.avatarImage
        setupActionBindings()
    }

    private func setupActionBindings() {
        let action = action.share()

        action
            .filter { $0 == .selectAvatar }
            .withUnretained(self)
            .sink { owner, _ in
                owner.showImagePickerActionSheet = true
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

//        validateName
//            .filter { $0 }
//            .withUnretained(self)
//            .flatMap { owner, _ in
//                owner.userService
//                    .updateUser(username: owner.currentName, avatar: owner.authenticationManager.currentUser?.avatarImage?.base64EncodedString())
//                    .track(activity: owner.primaryActivity)
//                    .materialize()
//                    .compactMap(\.value)
//            }
//            .map { _ -> Route in .dismissTapped }
//            .subscribe(route)
//            .store(in: cancelBag)
    }
}
