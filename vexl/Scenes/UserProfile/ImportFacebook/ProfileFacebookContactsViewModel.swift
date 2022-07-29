//
//  ImportContactsProfileViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 20/07/22.
//

import Foundation
import Cleevio

// TODO: - complete the implementation once the facebook issue (not fetching contacts) is solved.

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
