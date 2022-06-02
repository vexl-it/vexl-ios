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
    var currentValue: AnyPublisher<BitcoinData, Never> { get }
    var isFetching: AnyPublisher<Bool, Never> { get }

    func startFetchingCurrency(every interval: TimeInterval)
    func stopFetchingCurrency()
}

final class CryptocurrencyValueManager: CryptocurrencyValueManagerType {

    var currentValue: AnyPublisher<BitcoinData, Never> { currentValueSubject.filterNil().eraseToAnyPublisher() }
    var isFetching: AnyPublisher<Bool, Never> { activity.indicator.loading }

    @Inject private var userService: UserServiceType
    private let currentValueSubject: CurrentValueSubject<BitcoinData?, Never> = .init(nil)
    private let activity: Activity = .init()
    private var cancellable: AnyCancellable?

    func startFetchingCurrency(every interval: TimeInterval) {
        cancellable = Timer.publish(every: interval, on: RunLoop.main, in: .default)
            .autoconnect()
            .prepend(Date())
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<BitcoinData, Never> in
                owner.userService
                    .getBitcoinData()
                    .track(activity: owner.activity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .asOptional()
            .subscribe(currentValueSubject)
    }

    func stopFetchingCurrency() {
        cancellable = nil
    }
}
