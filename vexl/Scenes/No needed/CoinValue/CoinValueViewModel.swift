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

    @Inject var cryptocurrencyManager: CryptocurrencyValueManagerType

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoading: Bool
    @Published var primaryActivity: Activity = .init()
    @Published var bitcoinValue: Decimal?

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    @Inject private var userService: UserServiceType
    private let cancelBag: CancelBag = .init()

    init(startsLoading: Bool) {
        self.isLoading = startsLoading
        setupBindings()
    }

    private func setupBindings() {
        cryptocurrencyManager
            .currentValue
            .map(\.priceUsd)
            .asOptional()
            .assign(to: &$bitcoinValue)

        cryptocurrencyManager
            .isFetching
            .withUnretained(self)
            .sink { owner, isFetching in
                owner.isLoading = isFetching
            }
            .store(in: cancelBag)
    }
}
