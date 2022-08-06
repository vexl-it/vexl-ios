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
        case linkTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var hasAgreedTermsAndConditions = false

    var userFinished = false

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
        case termsAndConditionsTapped
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
            .map { _ -> Route in .continueTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .linkTap }
            .map { _ -> Route in .termsAndConditionsTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
