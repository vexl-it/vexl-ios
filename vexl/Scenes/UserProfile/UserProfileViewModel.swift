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
    @Inject var remoteConfigManager: RemoteConfigManagerType

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

    @Fetched(fetchImmediately: false)
    private var contacts: [ManagedContact]

    @Published var numberOfContacts: Int = 0

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

    @Published var username: String = ""
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
        case selectCurrency
        case donate
        case joinVexl
        case editName
        case editAvatar
        case importContacts
        case importFacebook
        case reportIssue
        case showGroups
        case deleteAccount
        case faq
        case termsAndPrivacy
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var options: [OptionGroup] {
        let isMarketplaceLocked = remoteConfigManager.getBoolValue(for: .isMarketplaceLocked)
        guard isMarketplaceLocked else { return Option.groupedOptions }
        return Option.lockedMarketplaceGroupedOptions
    }

    let bitcoinViewModel: BitcoinViewModel
    private let cancelBag: CancelBag = .init()

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        setupActivity()
        setupBindings()
        setupUpdateUser()
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

    private func setupUpdateUser() {
        let profile = userRepository.user?.profile

        profile?
            .publisher(for: \.name)
            .map { $0 ?? "" }
            .assign(to: &$username)

        profile?
            .publisher(for: \.avatarData)
            .compactMap { _ in profile?.avatar }
            .assign(to: &$avatar)

        $contacts
            .publisher
            .map(\.objects)
            .map { $0.count }
            .assign(to: &$numberOfContacts)

        $contacts
            .load(sortDescriptors: nil,
                  predicate: NSPredicate(format: "sourceRawType == %@", "phone"))
    }

    private func setupBindings() {
        action
            .filter { $0 == .joinVexl }
            .map { _ in .joinVexl }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .donate }
            .map { _ in .donate }
            .subscribe(route)
            .store(in: cancelBag)

        let option = action
            .compactMap { action -> Option? in
                if case let .itemTap(option) = action { return option }
                return nil
            }
            .share()

        option
            .filter { $0 == .faq }
            .map { _ in .faq }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .termsAndPrivacy }
            .map { _ in .termsAndPrivacy }
            .subscribe(route)
            .store(in: cancelBag)

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
            .map { _ in .importContacts }
            .subscribe(route)
            .store(in: cancelBag)

        // TODO: - Subscribe to route once the problems with facebook are fixed.
        option
            .filter { $0 == .facebook }
            .map { _ -> Route in .importFacebook }
            .sink()
            .store(in: cancelBag)

        option
            .filter { $0 == .reportIssue }
            .map { _ -> Route in .reportIssue }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .groups }
            .map { _ -> Route in .showGroups }
            .subscribe(route)
            .store(in: cancelBag)

        option
            .filter { $0 == .logout }
            .map { _ -> Route in .deleteAccount }
            .subscribe(route)
            .store(in: cancelBag)
    }

    func logoutUser() {
        authenticationManager.logoutUserPublisher(force: false)
            .sink()
            .store(in: cancelBag)
    }
}
