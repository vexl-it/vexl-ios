//
//  RegisterPhoneContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import Foundation
import Combine
import Cleevio
import SwiftUI

final class RegisterPhoneContactsViewModel: ViewModelType {

    @Inject var initialScreenManager: InitialScreenManager
    @Inject var authenticationManager: AuthenticationManager
    @Inject var userService: UserServiceType
    @Inject var contactsService: ContactsServiceType

    // MARK: - View State

    enum ViewState {
        case requestAccess
        case importPhoneContacts
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case nextTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Activities

    var primaryActivity: Activity = .init()
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    // MARK: - View Bindings

    @Published var loading = false
    @Published var error: Error?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case skipTapped
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Subviews View Models and State

    @Published var currentState: ViewState = .requestAccess
    var phoneViewModel: RequestAccessPhoneContactsViewModel
    var importPhoneContactsViewModel: ImportPhoneContactsViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        phoneViewModel = RequestAccessPhoneContactsViewModel(activity: primaryActivity)
        importPhoneContactsViewModel = ImportPhoneContactsViewModel()
        setupActivity()
        setupRequestPhoneContactsBindings()
        setupImportPhoneContactsBindings()
        initialScreenManager.update(onboardingState: .importContacts)
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)

        importPhoneContactsViewModel
            .$loading
            .assign(to: &$loading)

        importPhoneContactsViewModel
            .$error
            .assign(to: &$error)
    }

    private func setupRequestPhoneContactsBindings() {
        phoneViewModel.contactsImported
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .importPhoneContacts
                try? owner.importPhoneContactsViewModel.fetchContacts()
            }
            .store(in: cancelBag)
    }

    private func setupImportPhoneContactsBindings() {
        importPhoneContactsViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.initialScreenManager.update(onboardingState: .finished)
                // TODO: - Change it to `.continue` when facebook is active
                owner.route.send(.skipTapped)
            }
            .store(in: cancelBag)
    }
}
