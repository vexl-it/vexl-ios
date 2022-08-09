//
//  GroupsInputViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import Cleevio
import Combine

final class GroupsInputViewModel: ViewModelType, ObservableObject {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var groupCode = ""

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var isCodeValid: Bool {
        groupCode.count == 6
    }
    private let cancelBag: CancelBag = .init()

    // MARK: - Initialization

    init() {
        setupActions()
    }

    private func setupActions() {
        let action = action.share()

        action
            .filter { $0 == .continueTap }
            .map { _ -> Route in .continueTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
