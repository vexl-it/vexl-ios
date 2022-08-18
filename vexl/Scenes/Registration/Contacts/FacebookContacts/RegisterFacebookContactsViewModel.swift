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

final class RegisterFacebookContactsViewModel: ViewModelType {

    @Inject var initialScreenManager: InitialScreenManager
    @Inject var authenticationManager: AuthenticationManager
    @Inject var userService: UserServiceType
    @Inject var contactsService: ContactsServiceType

    // MARK: - View State

    enum ViewState {
        case requestAccess
        case importFacebookContacts
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
    var facebookViewModel: RequestAccessFacebookContactsViewModel
    var importFacebookContactsViewModel: ImportFacebookContactsViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        facebookViewModel = RequestAccessFacebookContactsViewModel(activity: primaryActivity)
        importFacebookContactsViewModel = ImportFacebookContactsViewModel()
        setupActivity()
        setupRequestFacebookContactsBindings()
        setupImportFacebookContactsBindings()
        initialScreenManager.update(onboardingState: .finished)
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)

        importFacebookContactsViewModel
            .$loading
            .assign(to: &$loading)

        importFacebookContactsViewModel
            .$error
            .assign(to: &$error)
    }

    private func setupRequestFacebookContactsBindings() {
        facebookViewModel.skipped
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.skipTapped)
            }
            .store(in: cancelBag)

        facebookViewModel.contactsImported
            .compactMap { result -> Error? in
                if case .failure(let error) = result {
                    return error
                }
                return nil
            }
            .assign(to: &$error)

        facebookViewModel.contactsImported
            .filter { result in
                if case .success = result {
                    return true
                }
                return false
            }
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .importFacebookContacts
                owner.fetchFacebookContacts()
            }
            .store(in: cancelBag)
    }

    private func fetchFacebookContacts() {
        do {
            try importFacebookContactsViewModel.fetchContacts()
        } catch let facebookError {
            error = facebookError
        }
    }

    private func setupImportFacebookContactsBindings() {
        importFacebookContactsViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.continueTapped)
            }
            .store(in: cancelBag)
    }
}
