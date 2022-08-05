//
//  LoginViewModel.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import UIKit
import Combine
import Cleevio

final class WelcomeViewModel: ViewModelType {

    @Inject var notificationManager: NotificationManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var hasAgreedTermsAndConditions = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        $hasAgreedTermsAndConditions
            .filter { $0 }
            .sink(receiveValue: { [notificationManager] _ in
                notificationManager.requestToken()
            })
            .store(in: cancelBag)

        action
            .filter { $0 == .continueTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.continueTapped)
            }
            .store(in: cancelBag)
    }
}
