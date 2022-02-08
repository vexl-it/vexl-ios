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
        case showRegistration
    }

    let action: Action<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoadingCountries: Bool = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case showRegistration
    }

    var route: Coordinating<Route> = .init()

    // MARK: - Variables

    var primaryActivity: Activity = .init()
    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    deinit {
        print("LOGIN VIEWMODEL DEINIT")
    }

    private func setupActions() {
        action
            .sink(receiveValue: { [weak self] action in
                switch action {
                case .dismissTap:
                    self?.route.send(.dismissTapped)
                case .showRegistration:
                    self?.route.send(.showRegistration)
                }
            })
            .store(in: cancelBag)
    }
}
