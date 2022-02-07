//
//  LoginViewModel.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import UIKit
import Combine
import Cleevio

final class LoginViewModel: ViewModelType {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case dismissTap
    }

    let action: Action<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoadingCountries: Bool = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: Coordinating<Route> = .init()

    // MARK: - Variables

    var primaryActivity: Activity = .init()
    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        action
            .sink(receiveValue: { [weak self] _ in
                self?.route.send(.dismissTapped)
            })
            .store(in: cancelBag)
    }
}
