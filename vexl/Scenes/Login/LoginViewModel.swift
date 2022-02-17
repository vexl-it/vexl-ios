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
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var hasAgreedTermsAndConditions = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        action
            .sink(receiveValue: { [weak self] action in
                switch action {
                case .dismissTap:
                    self?.route.send(.dismissTapped)
                case .continueTap:
                    break
                }
            })
            .store(in: cancelBag)
    }
}
