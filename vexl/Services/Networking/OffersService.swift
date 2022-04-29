//
//  OffersService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

typealias EncryptedOfferData = [String: String]

struct Offer {
    let minAmount: Double
    let maxAmount: Double

    var minAmountString: String {
        "\(minAmount)"
    }

    var maxAmountString: String {
        "\(maxAmount)"
    }
}

protocol OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferInitialData, Error>
    func generateOfferKeyPair() -> AnyPublisher<ECCKeys, Never>
    func encryptOffer(withContactKey contactKey: String, offerKey: ECCKeys, offer: Offer) -> AnyPublisher<EncryptedOfferData, Error>
}

final class OfferService: OfferServiceType {

    func getInitialOfferData() -> AnyPublisher<OfferInitialData, Error> {
        Future { promise in
            promise(.success(
                OfferInitialData.defaultValues
            ))
        }
        .eraseToAnyPublisher()
    }

    func generateOfferKeyPair() -> AnyPublisher<ECCKeys, Never> {
        Future { promise in
            let keyPair = ECCKeys()
            promise(.success(keyPair))
        }
        .eraseToAnyPublisher()
    }

    func encryptOffer(withContactKey contactPublicKey: String,
                      offerKey: ECCKeys,
                      offer: Offer) -> AnyPublisher<EncryptedOfferData, Error> {
        Future { promise in
            do {
                let minAmount = try offer.minAmountString.ecc.encrypt(publicKey: contactPublicKey)
                let maxAmount = try offer.maxAmountString.ecc.encrypt(publicKey: contactPublicKey)
                let offerPublicKey = try offerKey.publicKey.ecc.encrypt(publicKey: contactPublicKey)

                let body = [
                    "userPublicKey": contactPublicKey,
                    "offerPublicKey": offerPublicKey,
                    "amountTopLimit": maxAmount,
                    "amountBottomLimit": minAmount
                ]

                promise(.success(body))
            } catch {
                promise(.failure(EncryptionError.dataEncryption))
            }
        }
        .eraseToAnyPublisher()
    }
}
