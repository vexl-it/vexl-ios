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
    @Inject var userService: UserServiceType
    @Inject var offerService: OfferServiceType
    @Inject var contactService: ContactsServiceType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case itemTap(option: Option)
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
        authenticationManager.currentUser?.username ?? ""
    }

    var avatar: Data? {
        authenticationManager.currentUser?.avatarImage ?? R.image.onboarding.emptyAvatar()?.jpegData(compressionQuality: 1)
    }

    var options: [OptionGroup] {
        Option.groupedOptions
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
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
            .compactMap { action -> Option? in
                if case let .itemTap(option) = action, option == .logout { return option }
                return nil
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.logoutUser()
            }
            .store(in: cancelBag)
    }

    private func logoutUser() {

        let deleteUser = userService
            .deleteUser()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)

        let deleteContactUser = deleteUser
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.contactService
                    .deleteUser()
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }

        let deleteOffers = deleteContactUser
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.offerService
                    .deleteOffers()
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }

        deleteOffers
            .withUnretained(self)
            .sink { owner, _ in
                owner.authenticationManager.logoutUser()
            }
            .store(in: cancelBag)
    }
}
