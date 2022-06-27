//
//  CryptocoinValueManager.swift
//  vexl
//
//  Created by Diego Espinoza on 10/05/22.
//

import Foundation
import Combine
import Cleevio

protocol CryptocurrencyValueManagerType {
    var currentTimeline: CurrentValueSubject<TimelineOption, Never> { get }
    var chartIsExpanded: CurrentValueSubject<Bool, Never> { get }

    var currentCoinData: CurrentValueSubject<ContentState<CoinData>, Never> { get }
    var currentCoinChartData: CurrentValueSubject<ContentState<CoinChartData>, Never> { get }

    var selectedCurrency: CurrentValueSubject<Currency, Never> { get }

    func startPollingCoinData()
    func stopPollingCoinData()
    func fetchChart(option: TimelineOption)
    func stopFetchingChartData()

    func select(currency: Currency)

    func toggleExpand()
}

final class CryptocurrencyValueManager: CryptocurrencyValueManagerType {

    @Inject private var userService: UserServiceType

    let currentTimeline: CurrentValueSubject<TimelineOption, Never>
    let currentCoinData: CurrentValueSubject<ContentState<CoinData>, Never> = .init(.loading)
    let currentCoinChartData: CurrentValueSubject<ContentState<CoinChartData>, Never> = .init(.loading)
    let selectedCurrency: CurrentValueSubject<Currency, Never>
    let chartIsExpanded: CurrentValueSubject<Bool, Never> = .init(false)

    private var coinDataSubscription: Cancellable?
    private var coinChartSubscription: Cancellable?
    private let cancelBag: CancelBag = CancelBag()

    private static let maxSampleCount: Int = 500

    init(option: TimelineOption) {
        currentTimeline = .init(option)

        let currency: Currency = UserDefaults.standard.codable(forKey: .selectedCurrency) ?? .usd
        selectedCurrency = .init(currency)

        selectedCurrency
            .sink { UserDefaults.standard.set(value: $0, forKey: .selectedCurrency) }
            .store(in: cancelBag)
    }

    func startPollingCoinData() {
        if coinDataSubscription != nil {
            stopPollingCoinData()
        }
        coinDataSubscription = Timer.publish(every: Constants.bitcoinPollInterval, on: RunLoop.main, in: .default)
            .autoconnect()
            .prepend(Date())
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<ContentState<CoinData>, Never> in
                owner.userService
                    .getBitcoinData()
                    .map { data -> ContentState<CoinData> in
                        .content(data)
                    }
                    .catch { error in
                        Just(.error(error))
                    }
                    .eraseToAnyPublisher()
            }
            .subscribe(currentCoinData)
    }

    func stopPollingCoinData() {
        coinDataSubscription?.cancel()
        coinDataSubscription = nil
    }

    func fetchChart(option: TimelineOption) {
        if coinDataSubscription != nil {
            stopFetchingChartData()
        }
        currentTimeline.send(option)
        currentCoinChartData.send(.loading)
        coinChartSubscription = userService
            .getBitcoinChartData(currency: selectedCurrency.value, option: option)
            .map { chartData in
                if chartData.prices.count > Self.maxSampleCount {
                    let reduction = Int(chartData.prices.count / Self.maxSampleCount)
                    let prices = chartData.prices
                        .enumerated()
                        .filter { $0.offset.isMultiple(of: reduction) }
                        .map(\.element)
                    return CoinChartData(prices: prices)
                }
                return chartData
            }
            .map { data -> ContentState<CoinChartData> in
                .content(data)
            }
            .catch { error in
                Just(.error(error))
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, data in
                owner.currentCoinChartData.send(data)
            })
    }

    func stopFetchingChartData() {
        coinChartSubscription?.cancel()
        coinChartSubscription = nil
    }

    func select(currency: Currency) {
        selectedCurrency.send(currency)
        currentCoinChartData.send(.loading)
        fetchChart(option: currentTimeline.value)
    }

    func toggleExpand() {
        chartIsExpanded.send(!chartIsExpanded.value)
    }
}
