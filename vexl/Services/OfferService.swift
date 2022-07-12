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
    func updateOffers(encryptedOffers: [EncryptedOffer], offerId: String) -> AnyPublisher<EncryptedOffer, Error>

    // MARK: - Storage

    func getStoredOffers(fromType type: OfferTypeOption, fromSource source: OfferSourceOption) -> AnyPublisher<[Offer], Error>
    func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error>
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

    func getStoredOffers(fromType type: OfferTypeOption, fromSource source: OfferSourceOption) -> AnyPublisher<[Offer], Error> {
        localStorageService.getOffers()
            .map { offers -> [Offer] in
                var filteredOffers: [Offer] = []

                if type.contains(.buy) {
                    filteredOffers.append(contentsOf: offers.filter { $0.type == .buy })
                }

                if type.contains(.sell) {
                    filteredOffers.append(contentsOf: offers.filter { $0.type == .sell })
                }

                return filteredOffers
            }
            .map { offers -> [Offer] in
                var filteredOffers: [Offer] = []

                if source.contains(.created) {
                    filteredOffers.append(contentsOf: offers.filter { $0.source == .created })
                }

                if source.contains(.fetched) {
                    filteredOffers.append(contentsOf: offers.filter { $0.source == .fetched })
                }

                return filteredOffers
            }
            .eraseToAnyPublisher()
    }

    func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        localStorageService.saveOffers(offers, areCreated: areCreated)
    }

    func deleteOffers() -> AnyPublisher<Void, Error> {
        getStoredOffers(fromType: .all, fromSource: .all)
            .materialize()
            .compactMap(\.value)
            .map { $0.map(\.offerId) }
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

    func updateOffers(encryptedOffers: [EncryptedOffer], offerId: String) -> AnyPublisher<EncryptedOffer, Error> {
        request(type: EncryptedOffer.self, endpoint: OffersRouter.updateOffer(offer: encryptedOffers, offerId: offerId))
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
        let activePriceState = try offer.offerPriceTrigger.rawValue.ecc.encrypt(publicKey: contactPublicKey)
        let activePriceValue = try "\(offer.offerPriceTriggerValue)".ecc.encrypt(publicKey: contactPublicKey)
        let active = try offer.isActive.string.ecc.encrypt(publicKey: contactPublicKey)
        let commonFriends = try offer.commonFriends.map { try $0.ecc.encrypt(publicKey: contactPublicKey) }
        let groupUuid = try offer.groupUuid.rawValue.ecc.encrypt(publicKey: contactPublicKey)

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
                              groupUuid: groupUuid,
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
                              offerType: offerType,
                              activePriceState: activePriceState,
                              activePriceValue: activePriceValue,
                              active: active,
                              commonFriends: commonFriends)
    }
}
