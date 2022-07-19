//
//  ImportContactsProfileViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 18/07/22.
//

import Foundation
import Cleevio
import Combine

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
    var importContactViewModel = ImportPhoneContactsViewModel()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        setupActivityBindings()
        importContactViewModel.currentState = .loading
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
