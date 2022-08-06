//
//  TermsAndConditionsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import Foundation
import Cleevio
import Combine

final class TermsAndConditionsViewModel: ViewModelType {

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

    }
}
