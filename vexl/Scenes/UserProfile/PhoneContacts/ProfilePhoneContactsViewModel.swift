//
//  ImportContactsProfileViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 18/07/22.
//

import Foundation
import Cleevio
import Combine

final class ProfilePhoneContactsViewModel: ImportContactsViewModel {

    override var actionTitle: String {
        L.registerContactsUpdateButton()
    }

    override var shouldSelectAll: Bool {
        true
    }

    override init() {
        super.init()
        showActionButton = false
        showBackButton = true
        currentState = .loading
        setupActionBindings()
    }

    private func setupActionBindings() {
        $hasSelectedItem
            .withUnretained(self)
            .sink { owner, hasSelection in
                owner.showActionButton = hasSelection
            }
            .store(in: cancelBag)
    }

    override func fetchContacts() throws {
        @Inject var encryptionService: EncryptionServiceType

        let contacts = contactsManager.fetchPhoneContacts()

        encryptionService.hashContacts(contacts: contacts)
            .track(activity: primaryActivity)
            .withUnretained(self)
            .flatMap { owner, hashedPhones in
                owner.contactsManager
                    .getActivePhoneContacts(hashedPhones.map(\.1))
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .withUnretained(self)
            .sink { owner, availableContacts in
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}

final class ImportContactsProfileViewModel: ViewModelType, ObservableObject {

    enum UserAction: Equatable {
        case dismissTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

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
    var importContactViewModel = ProfilePhoneContactsViewModel()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        setupActivityBindings()
        setupImportContact()
    }

    private func setupImportContact() {
        importContactViewModel.primaryActivity = primaryActivity

        importContactViewModel
            .dismiss
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        importContactViewModel
            .completed
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        try? importContactViewModel.fetchContacts()
    }

    private func setupActivityBindings() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }
}
