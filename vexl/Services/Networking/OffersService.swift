//
//  OffersService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

typealias EncryptedOfferData = [String: Any]

struct Offer {
    let minAmount: Double
    let maxAmount: Double
    let description: String
    let feeState: String
    let feeAmount: Double
    let locationState: String
    let paymentMethods: [String]
    let btcNetwork: [String]
    let friendLevel: String

    var minAmountString: String {
        "\(minAmount)"
    }

    var maxAmountString: String {
        "\(maxAmount)"
    }

    var feeAmountString: String {
        "\(feeAmount)"
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
                let description = try offer.description.ecc.encrypt(publicKey: contactPublicKey)
                let feeState = try offer.feeState.ecc.encrypt(publicKey: contactPublicKey)
                let feeAmount = try offer.feeAmountString.ecc.encrypt(publicKey: contactPublicKey)
                let locationState = try offer.locationState.ecc.encrypt(publicKey: contactPublicKey)
                var paymentMethods: [String] = []
                var btcNetwork: [String] = []
                let friendLevel = try offer.friendLevel.ecc.encrypt(publicKey: contactPublicKey)
                let offerType = try "SELL".ecc.encrypt(publicKey: contactPublicKey)

                offer.paymentMethods.forEach { method in
                    if let encrypted = try? method.ecc.encrypt(publicKey: contactPublicKey) {
                        paymentMethods.append(encrypted)
                    }
                }

                offer.btcNetwork.forEach { network in
                    if let encrypted = try? network.ecc.encrypt(publicKey: contactPublicKey) {
                        btcNetwork.append(encrypted)
                    }
                }

                // TODO: - convert locations to the request.

                let body: [String: Any] = [
                    "userPublicKey": contactPublicKey,
                    "location": [],
                    "offerPublicKey": offerPublicKey,
                    "offerDescription": description,
                    "amountTopLimit": maxAmount,
                    "amountBottomLimit": minAmount,
                    "feeState": feeState,
                    "feeAmount": feeAmount,
                    "locationState": locationState,
                    "paymentMethod": paymentMethods,
                    "btcNetwork": btcNetwork,
                    "friendLevel": friendLevel,
                    "offerType": offerType
                ]

                promise(.success(body))
            } catch {
                promise(.failure(EncryptionError.dataEncryption))
            }
        }
        .eraseToAnyPublisher()
    }
}
