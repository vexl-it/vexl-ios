//
//  OffersService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

typealias EncryptedOfferData = [String: String]

protocol OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferData, Error>
    //func encryptOfferData(minAmount: Double) -> AnyPublisher<EncryptedOfferData, Error>
}

final class OfferService: OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferData, Error> {
        Future { promise in
            promise(.success(
                OfferData(minOffer: Constants.Offer.minAmount,
                          maxOffer: Constants.Offer.maxAmount,
                          minFee: Constants.Offer.minFee,
                          maxFee: Constants.Offer.maxFee,
                          currencySymbol: Constants.Offer.currencySymbol)
            ))
        }
        .eraseToAnyPublisher()
    }
    
//    func encryptOfferData(minAmount: Double) -> AnyPublisher<EncryptedOfferData, Error> {
//        Future { promise in
//            let minAmountString = try? "\(minAmount)".ecc.encrypt(publicKey: "")
//            promise(.success(["123": minAmountString ?? ""]))
//        }
//        .eraseToAnyPublisher()
//    }
}
