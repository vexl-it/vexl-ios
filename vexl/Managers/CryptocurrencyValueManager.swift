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
    var currentValue: CurrentValueSubject<BitcoinData, Never> { get set }
    var isFetching: PassthroughSubject<Bool, Never> { get set }

    func startFetchingCurrency()
}

final class CryptocurrencyValueManager: CryptocurrencyValueManagerType {

    @Inject var userService: UserServiceType

    var currentValue: CurrentValueSubject<BitcoinData, Never> = .init(.noValue)
    var isFetching: PassthroughSubject<Bool, Never> = .init()

    private let cancelBag: CancelBag = .init()

    func startFetchingCurrency() {
        userService
            .getBitcoinData()
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, data in
                owner.isFetching.send(false)
                owner.currentValue.send(data)
            }
            .store(in: cancelBag)
    }
}
