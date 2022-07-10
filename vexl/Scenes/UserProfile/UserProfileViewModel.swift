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

    // TODO: - Remove hardcoded values
    var username: String {
        userRepository.user?.profile?.name ?? ""
    }

    var avatar: Data? {
        userRepository.user?.profile?.avatar ?? R.image.onboarding.emptyAvatar()?.jpegData(compressionQuality: 0.5)
    }

    var options: [OptionGroup] {
        Option.groupedOptions
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case selectCurrency
        case donate
        case joinVexl
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    let bitcoinViewModel: BitcoinViewModel
    private let cancelBag: CancelBag = .init()

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        setupActivity()
        setupDataBindings()
        setupBindings()
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

        option
            .filter { $0 == .currency }
            .withUnretained(self)
            .map { _ in .selectCurrency }
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
