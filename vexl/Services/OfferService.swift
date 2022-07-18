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

    func getUserOffers(offerIds: [String]) -> AnyPublisher<[OfferPayload], Error>
    func getOffer(pageLimit: Int?) -> AnyPublisher<Paged<OfferPayload>, Error>

    // MARK: - Offer Creation

    func createOffer(
        offer: ManagedOffer, userPublicKey: String, fiendLevel: ContactFriendLevel, expiration: TimeInterval
    ) -> AnyPublisher<OfferPayload, Error>
    func deleteOffers() -> AnyPublisher<Void, Error>

    // MARK: - Storage

    func getStoredOffers() -> AnyPublisher<[Offer], Error>
    func storeOffers(offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error>
    func getStoredOfferIds(fromType option: OfferTypeOption) -> AnyPublisher<[String], Error>
    func getStoredOfferKeys(fromSource option: OfferSourceOption) -> AnyPublisher<[OfferKeys], Error>
}

final class OfferService: BaseService, OfferServiceType {

    @Inject private var localStorageService: LocalStorageServiceType
    @Inject private var contactsService: ContactsServiceType
    @Inject private var encryptionService: EncryptionServiceType
    @Inject private var authenticationManager: AuthenticationManagerType

    // MARK: - Offer Fetching

    func getUserOffers(offerIds: [String]) -> AnyPublisher<[OfferPayload], Error> {
        request(type: [OfferPayload].self, endpoint: OffersRouter.getUserOffers(offerIds: offerIds))
            .eraseToAnyPublisher()
    }

    func getOffer(pageLimit: Int?) -> AnyPublisher<Paged<OfferPayload>, Error> {
        request(type: Paged<OfferPayload>.self, endpoint: OffersRouter.getOffers(pageLimit: pageLimit))
            .eraseToAnyPublisher()
    }

    // MARK: - Offer Creation

    func createOffer(
        offer: ManagedOffer,
        userPublicKey: String,
        fiendLevel: ContactFriendLevel,
        expiration: TimeInterval
    ) -> AnyPublisher<OfferPayload, Error> {
        let contacts = contactsService
            .getAllContacts(
                friendLevel: fiendLevel,
                hasFacebookAccount: authenticationManager.facebookSecurityHeader != nil,
                pageLimit: Constants.pageMaxLimit
            )
            .map { contacts -> [ContactKey] in
                let contacts = contacts.phone.items
                    + contacts.facebook.items
                    + [ContactKey(publicKey: userPublicKey)]
                return Array(Set(contacts))
            }

        let encryptOffer = contacts
            .withUnretained(self)
            .flatMap { [encryptionService] owner, contacts in
                encryptionService
                    .encryptOffer(withContactKey: contacts.map(\.publicKey), offer: offer)
            }
            .eraseToAnyPublisher()

        let createOffer = encryptOffer
            .withUnretained(self)
            .flatMap { owner, offerPayloads -> AnyPublisher<OfferPayload, Error> in
                owner.request(
                    type: OfferPayload.self,
                    endpoint: OffersRouter.createOffer(
                        offerPayloads: offerPayloads,
                        expiration: expiration
                    )
                )
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return createOffer
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
                var filteredOffers: [Offer] = []

                if option.contains(.buy) {
                    filteredOffers.append(contentsOf: offers.filter { $0.type == .buy })
                }

                if option.contains(.sell) {
                    filteredOffers.append(contentsOf: offers.filter { $0.type == .sell })
                }

                return filteredOffers.map(\.offerId)
            }
            .eraseToAnyPublisher()
    }

    func getStoredOfferKeys(fromSource option: OfferSourceOption) -> AnyPublisher<[OfferKeys], Error> {
        localStorageService.getOffers()
            .map { offers -> [OfferKeys] in
                var filteredOffers: [Offer] = []

                if option.contains(.created) {
                    filteredOffers.append(contentsOf: offers.filter { $0.source == .created })
                }

                if option.contains(.fetched) {
                    filteredOffers.append(contentsOf: offers.filter { $0.source == .fetched })
                }

                return filteredOffers.map(\.keysWithId)
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
