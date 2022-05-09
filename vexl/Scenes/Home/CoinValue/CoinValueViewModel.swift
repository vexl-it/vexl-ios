//
//  HomeViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 03.05.2022.
//

import Foundation
import Cleevio
import Combine

final class CoinValueViewModel: ViewModelType {

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    var isLoading: AnyPublisher<Bool, Never> {
        primaryActivity.indicator.loading
    }

    @Published var primaryActivity: Activity = .init()
    @Published var bitcoinValue: Decimal?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    @Inject private var userService: UserServiceType
    private let cancelBag: CancelBag = .init()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        userService
            .getBitcoinData()
            .track(activity: primaryActivity)
            .map(\.priceUsd)
            .asOptional()
            .assign(to: &$bitcoinValue)
    }
}
