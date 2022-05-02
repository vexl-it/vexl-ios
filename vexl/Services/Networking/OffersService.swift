//
//  OffersService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

protocol OfferServiceType {
    func getInitialOfferData() -> AnyPublisher<OfferInitialData, Error>
    func encryptOffer(withContactKey publicKeys: [String], offerKey: ECCKeys, offer: Offer) -> AnyPublisher<[EncryptedOffer], Error>

    func getOffer() -> AnyPublisher<Paged<EncryptedOffer>, Error>
    func createOffer(encryptedOffers: [EncryptedOffer]) -> AnyPublisher<EncryptedOffer, Error>
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
                    let feeState = try offer.feeStateString.ecc.encrypt(publicKey: contactPublicKey)
                    let feeAmount = try offer.feeAmountString.ecc.encrypt(publicKey: contactPublicKey)
                    let locationState = try offer.locationStateString.ecc.encrypt(publicKey: contactPublicKey)
                    var paymentMethods: [String] = []
                    var btcNetwork: [String] = []
                    let friendLevel = try offer.friendLevelString.ecc.encrypt(publicKey: contactPublicKey)
                    let offerType = try offer.offerTypeString.ecc.encrypt(publicKey: contactPublicKey)

                    offer.paymentMethodsList.forEach { method in
                        if let encrypted = try? method.ecc.encrypt(publicKey: contactPublicKey) {
                            paymentMethods.append(encrypted)
                        }
                    }

                    offer.btcNetworkList.forEach { network in
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

    func getOffer() -> AnyPublisher<Paged<EncryptedOffer>, Error> {
        request(type: Paged<EncryptedOffer>.self, endpoint: OffersRouter.getOffers)
            .eraseToAnyPublisher()
    }

    func createOffer(encryptedOffers: [EncryptedOffer]) -> AnyPublisher<EncryptedOffer, Error> {
        request(type: EncryptedOffer.self, endpoint: OffersRouter.createOffer(offer: encryptedOffers))
            .eraseToAnyPublisher()
    }

    func storeOfferKey(key: ECCKeys, withId id: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
