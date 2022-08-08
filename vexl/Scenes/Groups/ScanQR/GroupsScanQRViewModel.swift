//
//  GroupScanQRViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import Cleevio

final class GroupsScanQRViewModel: ViewModelType, ObservableObject {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case dismissTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()

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
