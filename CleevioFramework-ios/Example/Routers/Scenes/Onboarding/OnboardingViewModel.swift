//
//  OnboardingViewModel.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import UIKit
import Combine
import Cleevio

final class OnboardingViewModel: ViewModelType {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case tapLogin
        case tapPresentModal
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoadingCountries: Bool = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case startLoginFlow
        case startModalFlow
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var primaryActivity: Activity = .init()
    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    deinit {
        print("\(self) DEINIT")
    }

    private func setupActions() {
        action
            .sink(receiveValue: { [weak self] action in
                switch action {
                case .tapLogin:
                    self?.route.send(.startLoginFlow)
                case .tapPresentModal:
                    self?.route.send(.startModalFlow)
                }
            })
            .store(in: cancelBag)
    }
}
