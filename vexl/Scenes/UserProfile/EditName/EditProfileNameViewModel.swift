//
//  EditProfileNameViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 14/07/22.
//

import Foundation
import Cleevio
import Combine

final class EditProfileNameViewModel: ViewModelType, ObservableObject {

    @Inject var userService: UserServiceType
    @Inject var authenticationManager: AuthenticationManagerType

    enum UserAction: Equatable {
        case dismissTap
        case updateName
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var currentName: String = ""

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

    init() {
        self.currentName = authenticationManager.currentUser?.username ?? ""
        setupActionBindings()
    }

    private func setupActionBindings() {
        let action = action.share()

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        let validateName = action
            .withUnretained(self)
            .filter { $0.1 == .updateName && !$0.0.currentName.isEmpty }
            .flatMap { owner, _ in
                owner.userService
                    .validateUsername(username: owner.currentName)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map(\.isAvailable)
            }

        validateName
            .filter { $0 }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.userService
                    .updateUser(username: owner.currentName, avatar: owner.authenticationManager.currentUser?.avatarImage?.base64EncodedString())
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
