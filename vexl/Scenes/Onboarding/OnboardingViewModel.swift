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
        case tap
    }

    let action: Action<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoadingCountries: Bool = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case tapped
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
        print("ONBOARDING VIEWMODEL DEINIT")
    }

    private func setupActions() {
        action
            .sink(receiveValue: { [weak self] _ in
                self?.route.send(.tapped)
            })
            .store(in: cancelBag)
    }
}
