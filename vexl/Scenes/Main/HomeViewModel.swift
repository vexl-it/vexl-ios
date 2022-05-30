//
//  HomeViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 27.05.2022.
//

import Foundation
import Cleevio
import Combine

final class HomeViewModel: ViewModelType, ObservableObject {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        setupDataBindings()
        setupActionBindings()
    }

    private func setupDataBindings() {
    }

    private func setupActionBindings() {
    }
}
