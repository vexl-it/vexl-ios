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
    func getNewOffers(pageLimit: Int?, lastSyncDate: Date) -> AnyPublisher<Paged<OfferPayload>, Error>

    // MARK: - Offer Creation

    func createOffer(
        offer: ManagedOffer, userPublicKey: String, fiendLevel: ContactFriendLevel, expiration: TimeInterval
    ) -> AnyPublisher<OfferPayload, Error>
    func deleteOffers() -> AnyPublisher<Void, Error>

    // MARK: - Storage

    func getStoredOffers() -> AnyPublisher<[ManagedOffer], Error>
    func storeOffers(offers: [ManagedOffer], areCreated: Bool) -> AnyPublisher<Void, Error>
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

    func getNewOffers(pageLimit: Int?, lastSyncDate: Date) -> AnyPublisher<Paged<OfferPayload>, Error> {
        request(type: Paged<OfferPayload>.self, endpoint: OffersRouter.getNewOffers(pageLimit: pageLimit, lastSyncDate: lastSyncDate))
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

        let commonFriends = contacts
            .flatMap { [contactsService] contacts in
                contactsService
                    .getCommonFriends(publicKeys: contacts.map(\.publicKey))
                    .catch { _ in Just([:]) }
                    .map { (contacts, $0) }
            }
            .map { contacts, hashes in
                contacts.map { contact -> (ContactKey, [String]) in
                    let commonFriends = hashes[contact.publicKey] ?? []
                    return (contact, commonFriends)
                }
            }

        let encryptOffer = commonFriends
            .flatMap { [encryptionService] contactsAndHashes in
                encryptionService
                    .encryptOffer(withContactKey: contactsAndHashes, offer: offer)
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

    func getStoredOffers() -> AnyPublisher<[ManagedOffer], Error> {
        // TODO: Implement a varient for this method in OfferRepository
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func storeOffers(offers: [ManagedOffer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        // TODO: Implement a varient for this method in OfferRepository
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getStoredOfferIds(fromType option: OfferTypeOption) -> AnyPublisher<[String], Error> {
        // TODO: Implement a varient for this method in OfferRepository
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getStoredOfferKeys(fromSource option: OfferSourceOption) -> AnyPublisher<[OfferKeys], Error> {
        // TODO: Implement a varient for this method in OfferRepository
        Just([])
            .setFailureType(to: Error.self)
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
