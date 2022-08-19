//
//  OfferService.swift
//  vexl
//
//  Created by Diego Espinoza on 26/04/22.
//

import Foundation
import Combine

protocol OfferServiceType {

    // MARK: Offer Fetching

    func getUserOffers(offerIds: [String]) -> AnyPublisher<[OfferPayload], Error>
    func getMyOffers(pageLimit: Int?) -> AnyPublisher<Paged<OfferPayload>, Error>
    func getNewOffers(pageLimit: Int?, lastSyncDate: Date) -> AnyPublisher<Paged<OfferPayload>, Error>
    func getDeletedOffers(knownOffers: [ManagedOffer]) -> AnyPublisher<[String], Error>

    // MARK: Offer Creation

    func createOffer(expiration: Date, offerPayloads: [OfferPayload]) -> AnyPublisher<OfferPayload, Error>
    func createNewPrivateParts(for offer: ManagedOffer, userPublicKey: String, receiverPublicKeys: [String]) -> AnyPublisher<Void, Error>

    // MARK: Offer Updating

    func updateOffers(offerID: String, offerPayloads: [OfferPayload]) -> AnyPublisher<OfferPayload, Error>
    func deleteOffers(offerIds: [String]) -> AnyPublisher<Void, Error>
    func deleteOfferPrivateParts(offerIds: [String], publicKeys: [String]) -> AnyPublisher<Void, Error>

    // MARK: Helper functions

    func getReceiverPublicKeys(friendLevel: ContactFriendLevel, group: ManagedGroup?, includeUserPublicKey userPublicKey: String?) -> AnyPublisher<[String], Error>
    func encryptOffer(offer: ManagedOffer, publicKeys: [String]) -> AnyPublisher<[OfferPayload], Error>
}

final class OfferService: BaseService, OfferServiceType {

    @Inject private var contactsService: ContactsServiceType
    @Inject private var encryptionService: EncryptionServiceType
    @Inject private var authenticationManager: AuthenticationManagerType

    // MARK: - Offer Endpoints

    func getUserOffers(offerIds: [String]) -> AnyPublisher<[OfferPayload], Error> {
        request(type: [OfferPayload].self, endpoint: OffersRouter.getUserOffers(offerIds: offerIds))
            .eraseToAnyPublisher()
    }

    func getMyOffers(pageLimit: Int?) -> AnyPublisher<Paged<OfferPayload>, Error> {
        request(type: Paged<OfferPayload>.self, endpoint: OffersRouter.getOffers(pageLimit: pageLimit))
            .eraseToAnyPublisher()
    }

    func getNewOffers(pageLimit: Int?, lastSyncDate: Date) -> AnyPublisher<Paged<OfferPayload>, Error> {
        request(type: Paged<OfferPayload>.self, endpoint: OffersRouter.getNewOffers(pageLimit: pageLimit, lastSyncDate: lastSyncDate))
    }

    func getDeletedOffers(knownOffers: [ManagedOffer]) -> AnyPublisher<[String], Error> {
        let offerIds = knownOffers.compactMap(\.id)
        guard !offerIds.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return request(type: OfferIdList.self, endpoint: OffersRouter.getDeletedOffers(knownOfferIds: offerIds))
            .map(\.offerIds)
            .eraseToAnyPublisher()
    }

    // MARK: - Offer Creation

    func createOffer(expiration: Date, offerPayloads: [OfferPayload]) -> AnyPublisher<OfferPayload, Error> {
        request(
            type: OfferPayload.self,
            endpoint: OffersRouter.createOffer(
                offerPayloads: offerPayloads,
                expiration: expiration.timeIntervalSince1970
            )
        )
        .eraseToAnyPublisher()
    }

    func createNewPrivateParts(for offer: ManagedOffer, userPublicKey: String, receiverPublicKeys: [String]) -> AnyPublisher<Void, Error> {
        guard let offerID = offer.id else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return encryptOffer(offer: offer, publicKeys: receiverPublicKeys)
            .withUnretained(self)
            .flatMap { owner, payloads in
                owner.request(endpoint: OffersRouter.createNewPrivateParts(offerID: offerID, offerPayloads: payloads))
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Offer updating

    func updateOffers(offerID: String, offerPayloads: [OfferPayload]) -> AnyPublisher<OfferPayload, Error> {
        request(
            type: OfferPayload.self,
            endpoint: OffersRouter.updateOffer(
                offer: offerPayloads,
                offerId: offerID
            )
        )
        .eraseToAnyPublisher()
    }

    func deleteOffers(offerIds: [String]) -> AnyPublisher<Void, Error> {
        if !offerIds.isEmpty {
            return request(endpoint: OffersRouter.deleteOffers(offerIds: offerIds))
        } else {
            return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }

    func deleteOfferPrivateParts(offerIds: [String], publicKeys: [String]) -> AnyPublisher<Void, Error> {
        if !offerIds.isEmpty {
            return request(endpoint: OffersRouter.deleteOfferPrivateParts(offerIds: offerIds, publicKeys: publicKeys))
        } else {
            return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }

    // MARK: Helper functions

    func getReceiverPublicKeys(friendLevel: ContactFriendLevel, group: ManagedGroup?, includeUserPublicKey userPublicKey: String?) -> AnyPublisher<[String], Error> {
        contactsService
            .getAllContacts(
                friendLevel: friendLevel,
                hasFacebookAccount: authenticationManager.facebookSecurityHeader != nil,
                pageLimit: Constants.pageMaxLimit
            )
            .flatMap { contacts -> AnyPublisher<[String], Never> in
                let myPubKeys = [userPublicKey].compactMap { $0 }
                    + contacts.phone.map(\.publicKey)
                    + contacts.facebook.map(\.publicKey)
                guard let group = group else {
                    return Just(Array(Set(myPubKeys)))
                        .eraseToAnyPublisher()
                }
                // If this dependency is defined in header, it would cause circular dependency
                @Inject var groupManager: GroupManagerType
                return groupManager
                    .getAllGroupMembers(group: group)
                    .catch { _ in Just([]) }
                    .map { groupMembers -> [String] in
                        Array(Set(groupMembers + myPubKeys))
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func encryptOffer(offer: ManagedOffer, publicKeys: [String]) -> AnyPublisher<[OfferPayload], Error> {
        let commonFriends = contactsService
            .getCommonFriends(publicKeys: publicKeys)
            .catch { _ in Just([:]) }
            .map { (publicKeys, $0) }
            .map { publicKeys, hashes -> [OfferEncprytionInput] in
                publicKeys.map { publicKey in
                    let commonFriends = hashes[publicKey] ?? []
                    return OfferEncprytionInput(receiverPublicKey: publicKey, commonFriends: commonFriends)
                }
            }

        return commonFriends
            .flatMap { [encryptionService] contactsAndHashes in
                encryptionService
                    .encryptOffer(withContactKey: contactsAndHashes, offer: offer)
            }
            .eraseToAnyPublisher()
    }
}
