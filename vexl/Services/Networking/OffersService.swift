//
//  OffersService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

struct OfferData {
    let minOffer: Int
    let maxOffer: Int

    let minFee: Double
    let maxFee: Double

    let locations: [OfferLocationItemData]

    let currencySymbol: String
}

protocol OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferData, Error>
}

final class OfferService: OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferData, Error> {
        Future { promise in
            promise(.success(
                OfferData(minOffer: 0,
                          maxOffer: 30_000,
                          minFee: 0,
                          maxFee: 10,
                          locations: [],
                          currencySymbol: "$")
            ))
        }
        .eraseToAnyPublisher()
    }
}
