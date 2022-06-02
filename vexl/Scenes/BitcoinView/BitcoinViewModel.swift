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

    enum UserAction: Equatable {
        case timelineTap(TimelineOption)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var isLoading: Bool = false
    @Published var timelineSelected: TimelineOption = .oneDayAgo
    @Published private var bitcoinData: BitcoinData?

    let timelineOptions: [TimelineOption] = TimelineOption.allCases

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    var bitcoinWithCurrency: String {
        guard let value = bitcoinData?.priceUsd else { return "-" }
        return "$ \(value)"
    }

    var bitcoinIncreased: Bool { bitcoinData?.bitcoinIncreased(for: timelineSelected) ?? true }
    var bitcoinPercentageVariation: String { timelineSelected.variation(percentage: bitcoinPercentage) }
    private var bitcoinPercentage: String { bitcoinData?.getPercentage(for: timelineSelected) ?? "-" }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {}

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var primaryActivity: Activity = .init()
    private let cancelBag: CancelBag = .init()

    init() {
        setupActionBindings()
        setupDataBindings()
    }

    private func setupActionBindings() {
        action
            .compactMap { if case let .timelineTap(option) = $0 { return option } else { return nil } }
            .assign(to: &$timelineSelected)
    }

    private func setupDataBindings() {
        cryptocurrencyManager
            .currentValue
            .filter { !$0.priceUsd.isZero }
            .asOptional()
            .assign(to: &$bitcoinData)

        cryptocurrencyManager
            .isFetching
            .withUnretained(self)
            .sink { owner, isFetching in
                owner.isLoading = isFetching
            }
            .store(in: cancelBag)
    }
}
