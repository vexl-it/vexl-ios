//
//  RegisterPhoneContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import Combine
import Cleevio
import SwiftUI

final class RegisterContactsViewModel: ViewModelType {

    @Inject var authenticationManager: AuthenticationManager
    @Inject var userService: UserServiceType
    @Inject var contactsService: ContactsServiceType

    // MARK: - View State

    enum ViewState {
        case phone
        case importPhoneContacts
        case facebook
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

    @Published var currentState: ViewState = .phone
    var phoneViewModel: RequestAccessPhoneContactsViewModel
    var facebookViewModel: RequestAccessFacebookContactsViewModel
    var importPhoneContactsViewModel: ImportPhoneContactsViewModel
    var importFacebookContactsViewModel: ImportFacebookContactsViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init(username: String, avatar: Data?) {
        phoneViewModel = RequestAccessPhoneContactsViewModel(username: username, avatar: avatar, activity: primaryActivity)
        importPhoneContactsViewModel = ImportPhoneContactsViewModel()
        facebookViewModel = RequestAccessFacebookContactsViewModel(username: username, avatar: avatar, activity: primaryActivity)
        importFacebookContactsViewModel = ImportFacebookContactsViewModel()
        setupActivity()
        setupRequestPhoneContactsBindings()
        setupImportPhoneContactsBindings()
        setupRequestFacebookContactsBindings()
        setupImportFacebookContactsBindings()
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

        importFacebookContactsViewModel
            .$loading
            .assign(to: &$loading)

        importFacebookContactsViewModel
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
                owner.currentState = .facebook
                owner.importPhoneContactsViewModel.currentState = .loading
            }
            .store(in: cancelBag)
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

    func updateToPreviousState() {
        switch currentState {
        case .importPhoneContacts:
            phoneViewModel.currentState = .initial
            currentState = .phone
        case .importFacebookContacts:
            facebookViewModel.currentState = .initial
            currentState = .facebook
        case .phone, .facebook:
            break
        }
    }
}
