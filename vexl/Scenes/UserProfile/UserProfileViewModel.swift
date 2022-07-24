//
//  UserProfileViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import Cleevio
import SwiftUI
import Combine

final class UserProfileViewModel: ViewModelType, ObservableObject {

    @Inject var authenticationManager: AuthenticationManagerType
    @Inject var userRepository: UserRepositoryType
    @Inject var contactService: ContactsServiceType
    @Inject var userService: UserServiceType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case itemTap(option: Option)
        case donate
        case joinVexl
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var numberOfContacts: Int = 0

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    @Published var username: String = ""
    @Published var avatar: Data?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case selectCurrency
        case donate
        case joinVexl
        case editName
        case editAvatar
        case importContacts
        case importFacebook
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var options: [OptionGroup] {
        Option.groupedOptions
    }

    let bitcoinViewModel: BitcoinViewModel
    private let cancelBag: CancelBag = .init()

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        setupActivity()
        setupDataBindings()
        setupBindings()
        setupUpdateUser()
        self.username = userRepository.user?.profile?.name ?? ""
        self.avatar = userRepository.user?.profile?.avatar
    }

    func subtitle(for item: UserProfileViewModel.Option) -> String? {
        switch item {
        case .contacts:
            guard numberOfContacts > 0 else {
                return nil
            }
            return item.subtitle(withParam: "\(numberOfContacts)")
        default:
            return nil
        }
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupDataBindings() {
        contactService
            .countPhoneContacts()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .assign(to: &$numberOfContacts)
    }

    private func setupUpdateUser() {
        userRepository.user?.profile?
            .publisher(for: \.name)
            .map { $0 ?? "" }
            .assign(to: &$username)

        userRepository.user?.profile?
            .publisher(for: \.avatar)
            .compactMap { $0 }
            .assign(to: &$avatar)
    }

    private func setupBindings() {
        action
            .filter { $0 == .joinVexl }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.joinVexl)
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .donate }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.donate)
            }
            .store(in: cancelBag)

        let option = action
            .compactMap { action -> Option? in
                if case let .itemTap(option) = action { return option }
                return nil
            }
            .share()

        option
            .filter { $0 == .currency }
            .map { _ in .selectCurrency }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .editName }
            .map { _ in .editName }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .editAvatar }
            .map { _ in .editAvatar }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .contacts }
            .withUnretained(self)
            .map { _ -> Route in .importContacts }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .facebook }
            .map { _ -> Route in .importFacebook }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .logout }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.authenticationManager.logoutUserPublisher(force: false)
            }
            .sink()
            .store(in: cancelBag)
    }
}
