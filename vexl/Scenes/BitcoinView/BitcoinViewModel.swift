//
//  BitcoinViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 30.05.2022.
//

import Cleevio
import SwiftUI
import Combine
import SwiftUICharts

final class BitcoinViewModel: ViewModelType, ObservableObject {
    @Inject var cryptocurrencyManager: CryptocurrencyValueManagerType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case timelineTap(TimelineOption)
        case toggleExpand
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var timelineSelected: TimelineOption = .oneDayAgo
    @Published var isExpanded: Bool = false
    @Published private var coinDataState: ContentState<CoinData> = .loading
    @Published private var coinChartDataState: ContentState<CoinChartData> = .loading

    var isLoadingCoinData: Bool { coinDataState == .loading }
    var isLoadingChartData: Bool { coinChartDataState == .loading }

    let timelineOptions: [TimelineOption] = TimelineOption.allCases

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    var chartDataPoints: [LineChartDataPoint] {
        coinChartDataState.data?.prices
            .map { $0[1] }
            .map { LineChartDataPoint(value: $0) } ?? []
    }

    var currency: Currency { cryptocurrencyManager.selectedCurrency.value }

    var bitcoinValue: String {
        guard let value = coinDataState.data?.price(for: currency) else { return "-" }
        return Formatters.numberFormatter.string(for: value) ?? "-"
    }

    var bitcoinIncreased: Bool { coinDataState.data?.bitcoinIncreased(for: timelineSelected) ?? true }
    var bitcoinPercentageVariation: String { timelineSelected.variation(percentage: bitcoinPercentage) }

    private var bitcoinPercentage: String { coinDataState.data?.getPercentage(for: timelineSelected) ?? "-" }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {}

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var primaryActivity: Activity = .init()
    private let cancelBag: CancelBag = .init()
    private var enableNextChartAnimation: Bool = false

    init() {
        setupActionBindings()
        setupDataBindings()
    }

    private func setupActionBindings() {
        action
            .compactMap { action -> TimelineOption? in if case let .timelineTap(option) = action { return option } else { return nil } }
            .withUnretained(self)
            .sink(receiveValue: { owner, option in
                owner.cryptocurrencyManager.fetchChart(option: option)
            })
            .store(in: cancelBag)

        action
            .filter { $0 == .toggleExpand }
            .withUnretained(self)
            .sink { owner, _ in
                owner.enableNextChartAnimation = true
                owner.cryptocurrencyManager.toggleExpand()
            }
            .store(in: cancelBag)
    }

    private func setupDataBindings() {
        cryptocurrencyManager
            .currentCoinData
            .withUnretained(self)
            .sink(receiveValue: { owner, state in
                owner.coinDataState = state
            })
            .store(in: cancelBag)

        cryptocurrencyManager
            .currentCoinChartData
            .withUnretained(self)
            .sink(receiveValue: { owner, state in
                owner.coinChartDataState = state
            })
            .store(in: cancelBag)

        cryptocurrencyManager
            .currentTimeline
            .withUnretained(self)
            .sink(receiveValue: { owner, timeline in
                owner.timelineSelected = timeline
            })
            .store(in: cancelBag)

        cryptocurrencyManager
            .chartIsExpanded
            .withUnretained(self)
            .sink { owner, expand in
                owner.isExpanded = expand
            }
            .store(in: cancelBag)
    }
}
