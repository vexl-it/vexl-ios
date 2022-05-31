//
//  BitcoinViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import Cleevio
import SwiftUI
import Combine

final class BitcoinViewModel: ViewModelType, ObservableObject {
    @Inject var cryptocurrencyManager: CryptocurrencyValueManagerType

    // MARK: - Action Binding

    enum UserAction: Equatable {}

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoading: Bool = false
    @Published private var bitcoinValue: Decimal?

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    var bitcoinWithCurrency: String {
        guard let value = bitcoinValue else { return "-" }
        return "$ \(value)"
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {}

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var primaryActivity: Activity = .init()
    private let cancelBag: CancelBag = .init()

    init() {
        setupDataBindings()
    }

    private func setupDataBindings() {
        cryptocurrencyManager
            .currentValue
            .map(\.priceUsd)
            .filter { !$0.isZero }
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
