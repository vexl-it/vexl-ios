//
//  CoinViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import Cleevio

final class CoinViewModel: ViewModelType, ObservableObject {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case contentTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var isExpanded = false
    
    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()
}
