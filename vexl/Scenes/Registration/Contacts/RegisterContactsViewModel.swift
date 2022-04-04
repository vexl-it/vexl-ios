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
    @Published var error: AlertError?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Subviews View Models and State

    @Published var currentState: ViewState = .phone
    var phoneViewModel: RequestAccessContactsViewModel
    var facebookViewModel: RequestAccessContactsViewModel
    var importPhoneContactsViewModel: ImportPhoneContactsViewModel
    var importFacebookContactsViewModel: ImportFacebookContactsViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init(username: String) {
        phoneViewModel = RequestAccessPhoneContactsViewModel(username: username)
        importPhoneContactsViewModel = ImportPhoneContactsViewModel()
        facebookViewModel = RequestAccessFacebookContactsViewModel(username: username)
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
            .withUnretained(self)
            .sink { owner, error in
                owner.error = AlertError(error: error)
            }
            .store(in: cancelBag)
    }

    private func setupRequestPhoneContactsBindings() {
        phoneViewModel.accessConfirmed
            .withUnretained(self)
            .sink { owner, _ in
                owner.phoneViewModel.currentState = .completed
            }
            .store(in: cancelBag)

        phoneViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .importPhoneContacts
                owner.phoneViewModel.currentState = .initial
                owner.importPhoneContactsViewModel.fetchContacts()
            }
            .store(in: cancelBag)
    }

    private func setupImportPhoneContactsBindings() {
        importPhoneContactsViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .facebook
                owner.importPhoneContactsViewModel.currentState = .none
            }
            .store(in: cancelBag)
    }

    private func setupRequestFacebookContactsBindings() {
        facebookViewModel.skipped
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.continueTapped)
            }
            .store(in: cancelBag)

        let loginFacebookUser = facebookViewModel.accessConfirmed
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.authenticationManager
                    .loginWithFacebook(fromViewController: nil)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .eraseToAnyPublisher()
            }
            .compactMap { response -> String? in
                guard let value = response.value, let facebookId = value else {
                    return nil
                }
                return facebookId
            }

        loginFacebookUser
            .withUnretained(self)
            .flatMap { owner, facebookId in
                owner.userService
                    .facebookSignature(id: facebookId)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .eraseToAnyPublisher()
            }
            .compactMap { $0.value }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, response in
                if !response.challengeVerified {
                    owner.error = AlertError(error: UserError.facebookValidation)
                }
            })
            .filter { $0.1.challengeVerified }
            .sink { owner, _ in
                owner.facebookViewModel.currentState = .completed
            }
            .store(in: cancelBag)

        facebookViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .importFacebookContacts
                owner.facebookViewModel.currentState = .initial
                owner.importFacebookContactsViewModel.fetchContacts()
            }
            .store(in: cancelBag)
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
