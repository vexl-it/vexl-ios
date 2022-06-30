//
//  OfferService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

protocol OfferServiceType {

    // MARK: - Offer Fetching

    func getUserOffers(offerIds: [String]) -> AnyPublisher<[EncryptedOffer], Error>
    func getOffer(pageLimit: Int?) -> AnyPublisher<Paged<EncryptedOffer>, Error>

    // MARK: - Offer Creation

    func getInitialOfferData() -> AnyPublisher<OfferInitialData, Error>
    func encryptOffer(withContactKey publicKeys: [String], offerKey: ECCKeys, offer: Offer) -> AnyPublisher<[EncryptedOffer], Error>
    func createOffer(encryptedOffers: [EncryptedOffer], expiration: TimeInterval) -> AnyPublisher<EncryptedOffer, Error>
    func deleteOffers() -> AnyPublisher<Void, Error>

    // MARK: - Storage

    func getStoredOffers() -> AnyPublisher<[Offer], Error>
    func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error>
    func getStoredOfferIds(fromType option: OfferTypeOption) -> AnyPublisher<[String], Error>
    func getStoredOfferKeys(fromSource option: OfferSourceOption) -> AnyPublisher<[OfferKeys], Error>
}

final class OfferService: BaseService, OfferServiceType {

    @Inject var localStorageService: LocalStorageServiceType

    // MARK: - Offer Fetching

    func getUserOffers(offerIds: [String]) -> AnyPublisher<[EncryptedOffer], Error> {
        request(type: [EncryptedOffer].self, endpoint: OffersRouter.getUserOffers(offerIds: offerIds))
            .eraseToAnyPublisher()
    }

    func getOffer(pageLimit: Int?) -> AnyPublisher<Paged<EncryptedOffer>, Error> {
        request(type: Paged<EncryptedOffer>.self, endpoint: OffersRouter.getOffers(pageLimit: pageLimit))
            .eraseToAnyPublisher()
    }

    // MARK: - Offer Creation

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
        Future { [weak self] promise in
            if let owner = self {
                do {
                    var offerList: [EncryptedOffer] = []

                    for contactPublicKey in publicKeys {
                        let encryptedOffer = try owner.encrypt(offer: offer, withOfferKey: offerKey, publicKey: contactPublicKey)
                        offerList.append(encryptedOffer)
                    }

                    promise(.success(offerList))
                } catch {
                    promise(.failure(EncryptionError.dataEncryption))
                }
            } else {
                promise(.failure(EncryptionError.noOfferService))
            }
        }
        .eraseToAnyPublisher()
    }

    func createOffer(encryptedOffers: [EncryptedOffer], expiration: TimeInterval) -> AnyPublisher<EncryptedOffer, Error> {
        request(type: EncryptedOffer.self, endpoint: OffersRouter.createOffer(offer: encryptedOffers, expiration: expiration))
            .eraseToAnyPublisher()
    }

    // MARK: - Storage

    func getStoredOffers() -> AnyPublisher<[Offer], Error> {
        localStorageService.getOffers()
    }

    func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        localStorageService.saveOffers(offers, areCreated: areCreated)
    }

    func getStoredOfferIds(fromType option: OfferTypeOption) -> AnyPublisher<[String], Error> {
        localStorageService.getOffers()
            .map { offers -> [String] in
                guard !option.contains(.all) && !option.contains([.buy, .sell]) else {
                    return offers.map(\.offerId)
                }

                if option.contains(.buy) {
                    return offers
                        .filter { $0.type == .buy }
                        .map(\.offerId)
                } else if option.contains(.sell) {
                    return offers
                        .filter { $0.type == .sell }
                        .map(\.offerId)
                }

                return []
            }
            .eraseToAnyPublisher()
    }

    func getStoredOfferkeys(fromSource option: OfferSourceOption) -> AnyPublisher<[OfferKeys], Error> {
        localStorageService.getOffers()
            .map { offers -> [OfferKeys] in
                guard !option.contains(.all) && !option.contains([.created, .fetched]) else {
                    return offers.map(\.keysWithId)
                }

                if option.contains(.created) {
                    return offers
                        .filter { $0.source == .created }
                        .map(\.keysWithId)
                } else if option.contains(.fetched) {
                    return offers
                        .filter { $0.source == .fetched }
                        .map(\.keysWithId)
                }

                return []
            }
            .eraseToAnyPublisher()
    }

    func deleteOffers() -> AnyPublisher<Void, Error> {
        getStoredOfferIds(fromType: .all)
            .withUnretained(self)
            .flatMap { owner, offerIds -> AnyPublisher<Void, Error> in
                if !offerIds.isEmpty {
                    // TODO: - clean from the localstorage too
                    return owner.request(endpoint: OffersRouter.deleteOffers(offerIds: offerIds))
                } else {
                    return Just(()).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

extension OfferService {
    // TODO: - add some optimizations so that the encryption is done in multiple threads

    private func encrypt(offer: Offer, withOfferKey offerKey: ECCKeys, publicKey contactPublicKey: String) throws -> EncryptedOffer {
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

        // TODO: - convert locations to JSON and then to string and set real Location

        let fakeLocation = OfferLocation(latitude: 14.418_540,
                                         longitude: 50.073_658,
                                         radius: 1)
        let locationString = fakeLocation.asString ?? ""
        let encryptedString = try? locationString.ecc.encrypt(publicKey: contactPublicKey)

        return EncryptedOffer(userPublicKey: contactPublicKey,
                              location: [encryptedString ?? ""],
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
    }
}
