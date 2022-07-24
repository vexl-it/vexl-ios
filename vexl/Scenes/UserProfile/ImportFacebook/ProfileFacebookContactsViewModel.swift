//
//  ImportContactsProfileViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 20/07/22.
//

import Foundation
import Cleevio

final class ProfileImportFacebookViewModel: ImportContactsViewModel {
    override func fetchContacts() throws {

        @Inject var facebookManager: FacebookManagerType

        guard let facebookId = facebookManager.facebookID,
              let facebookToken = facebookManager.facebookToken else {
                  throw UserError.fetchFacebookFriends
              }

        let facebookContacts = contactsManager
            .fetchFacebookContacts(id: facebookId, accessToken: facebookToken)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)

        facebookContacts
            .map { $0.map { $0.id } }
            .withUnretained(self)
            .flatMap { owner, contactIds in

                // Fetch facebook friends that can be imported/have not been imported to the Backend

                owner.contactsManager
                    .getActiveFacebookContacts(contactIds, withId: facebookId, token: facebookToken)
                    .track(activity: owner.primaryActivity)
                    .materialize()
            }
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, availableContacts in
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}

final class ProfileFacebookContactsViewModel: ViewModelType, ObservableObject {

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
    var importContactViewModel = ProfileImportFacebookViewModel()

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
