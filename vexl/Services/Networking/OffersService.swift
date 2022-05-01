//
//  OffersService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

struct Offer {
    
    enum `Type`: String {
        case sell = "SELL"
        case buy = "BUY"
    }
    
    let minAmount: Int
    let maxAmount: Int
    let description: String
    let feeState: String
    let feeAmount: Double
    let locationState: String
    let paymentMethods: [String]
    let btcNetwork: [String]
    let friendLevel: String
    let type: `Type`

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
    func encryptOffer(withContactKey publicKeys: [String], offerKey: ECCKeys, offer: Offer) -> AnyPublisher<[EncryptedOffer], Error>
//    func encryptOffer(withContactKey publicKeys: [String], offerKey: ECCKeys, offer: Offer) -> [EncryptedOffer]
    func createOffer(encryptedOffers: [EncryptedOffer]) -> AnyPublisher<CreatedOffer, Error>
    func storeOfferKey(key: ECCKeys, withId id: String) -> AnyPublisher<Void, Error>
}

final class OfferService: BaseService, OfferServiceType {

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

    func encryptOffer(withContactKey publicKeys: [String], offerKey: ECCKeys, offer: Offer) -> [EncryptedOffer] {
        do {
            var offerList: [EncryptedOffer] = []
            for contactPublicKey in publicKeys {
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

                // TODO: - convert locations to JSON and then to string.

                let encryptedOffer = EncryptedOffer(userPublicKey: contactPublicKey,
                                                    location: [],
                                                    offerPublicKey: offerPublicKey,
                                                    offerDescription: description,
                                                    amountTopLimit: maxAmount,
                                                    amountBottomLimit: minAmount,
                                                    feeState: feeState,
                                                    feeAmount: feeAmount,
                                                    locationState: locationState,
                                                    paymentMethod: paymentMethods,
                                                    btcNetwork: btcNetwork,
                                                    friendLevel: friendLevel,
                                                    offerType: offerType)

                offerList.append(encryptedOffer)
            }

            return offerList
        } catch {
            return []
        }
    }

    func encryptOffer(withContactKey publicKeys: [String],
                      offerKey: ECCKeys,
                      offer: Offer) -> AnyPublisher<[EncryptedOffer], Error> {
        Future { promise in
            do {
                var offerList: [EncryptedOffer] = []
                for contactPublicKey in publicKeys {
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
                    let offerType = try offer.type.rawValue.ecc.encrypt(publicKey: contactPublicKey)

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

                    // TODO: - convert locations to JSON and then to string.

                    let encryptedOffer = EncryptedOffer(userPublicKey: contactPublicKey,
                                                        location: [],
                                                        offerPublicKey: offerPublicKey,
                                                        offerDescription: description,
                                                        amountTopLimit: maxAmount,
                                                        amountBottomLimit: minAmount,
                                                        feeState: feeState,
                                                        feeAmount: feeAmount,
                                                        locationState: locationState,
                                                        paymentMethod: paymentMethods,
                                                        btcNetwork: btcNetwork,
                                                        friendLevel: friendLevel,
                                                        offerType: offerType)

                    offerList.append(encryptedOffer)
                }

                promise(.success(offerList))
            } catch {
                promise(.failure(EncryptionError.dataEncryption))
            }
        }
        .eraseToAnyPublisher()
    }

    func createOffer(encryptedOffers: [EncryptedOffer]) -> AnyPublisher<CreatedOffer, Error> {
        request(type: CreatedOffer.self, endpoint: OffersRouter.createOffer(offer: encryptedOffers))
            .eraseToAnyPublisher()
    }

    func storeOfferKey(key: ECCKeys, withId id: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
