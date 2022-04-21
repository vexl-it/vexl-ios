//
//  CreateOfferViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import Foundation
import Cleevio
import SwiftUI

class CreateOfferViewModel: ViewModelType, ObservableObject {

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case pause
        case delete
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
    let currencySymbol = "$"

    init() {
        setupBindings()
    }

    private func setupBindings() {
        action
            .filter { $0 == .dismissTap }
            .withUnretained(self)
            .sink { owner, _ in
                owner.route.send(.dismissTapped)
            }
            .store(in: cancelBag)
    }
}
