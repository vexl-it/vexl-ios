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
    func getMyOffers(pageLimit: Int?) -> AnyPublisher<OfferPayloadListWrapper, Error>
    func getNewOffers(pageLimit: Int?, lastSyncDate: Date) -> AnyPublisher<OfferPayloadListWrapper, Error>
    func getDeletedOffers(knownOffers: [ManagedOffer]) -> AnyPublisher<[String], Error>

    // MARK: Offer Creation

    func createOffer(offerPayload: OfferRequestPayload) -> AnyPublisher<OfferPayload, Error>
    func createNewPrivateParts(for offer: ManagedOffer, envelope: PKsEnvelope) -> AnyPublisher<Void, Error>

    // MARK: Offer Updating

    func report(offerID: String) -> AnyPublisher<Void, Error>
    func updateOffers(adminID: String, offerPayload: OfferRequestPayload) -> AnyPublisher<OfferPayload, Error>
    func deleteOffers(adminIDs: [String]) -> AnyPublisher<Void, Error>
    func deleteOfferPrivateParts(adminIDs: [String], publicKeys: [String]) -> AnyPublisher<Void, Error>

    // MARK: Helper functions

    func getReceiverPublicKeys(friendLevel: ContactFriendLevel, groups: [ManagedGroup], includeUserPublicKey userPublicKey: String) -> AnyPublisher<PKsEnvelope, Error>
    func encryptOffer(offer: ManagedOffer, envelope: PKsEnvelope) -> AnyPublisher<OfferRequestPayload, Error>
    func generateOfferPayloadPrivateParts(envelope: PKsEnvelope, symmetricKey: String) -> AnyPublisher<[OfferPayloadPrivateWrapper], Never>
    func encryptOfferPayloadPrivateParts(privateParts: [OfferPayloadPrivateWrapper]) -> AnyPublisher<[OfferPayloadPrivateWrapperEncrypted], Error>
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

    func getMyOffers(pageLimit: Int?) -> AnyPublisher<OfferPayloadListWrapper, Error> {
        request(type: OfferPayloadListWrapper.self, endpoint: OffersRouter.getOffers(pageLimit: pageLimit))
            .eraseToAnyPublisher()
    }

    func getNewOffers(pageLimit: Int?, lastSyncDate: Date) -> AnyPublisher<OfferPayloadListWrapper, Error> {
        request(type: OfferPayloadListWrapper.self, endpoint: OffersRouter.getNewOffers(pageLimit: pageLimit, lastSyncDate: lastSyncDate))
    }

    func getDeletedOffers(knownOffers: [ManagedOffer]) -> AnyPublisher<[String], Error> {
        let offerIds = knownOffers.compactMap(\.offerID)
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

    func createOffer(offerPayload: OfferRequestPayload) -> AnyPublisher<OfferPayload, Error> {
        request(
            type: OfferPayload.self,
            endpoint: OffersRouter.createOffer(
                offerPayload: offerPayload
            )
        )
        .eraseToAnyPublisher()
    }

    func createNewPrivateParts(for offer: ManagedOffer, envelope: PKsEnvelope) -> AnyPublisher<Void, Error> {
        guard let adminID = offer.adminID, let symmetricKey = offer.symmetricKey else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return generateOfferPayloadPrivateParts(envelope: envelope, symmetricKey: symmetricKey)
            .withUnretained(self)
            .flatMap { owner, privateParts in
                owner.encryptOfferPayloadPrivateParts(privateParts: privateParts)
            }
            .withUnretained(self)
            .flatMap { owner, payloads in
                owner.request(endpoint: OffersRouter.createNewPrivateParts(adminID: adminID, offerPrivateParts: payloads))
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Offer updating

    func report(offerID: String) -> AnyPublisher<Void, Error> {
        request(endpoint: OffersRouter.report(offerID: offerID))
    }

    func updateOffers(adminID: String, offerPayload: OfferRequestPayload) -> AnyPublisher<OfferPayload, Error> {
        request(
            type: OfferPayload.self,
            endpoint: OffersRouter.updateOffer(
                offerPayload: offerPayload,
                adminID: adminID
            )
        )
        .eraseToAnyPublisher()
    }

    func deleteOffers(adminIDs: [String]) -> AnyPublisher<Void, Error> {
        if !adminIDs.isEmpty {
            return request(endpoint: OffersRouter.deleteOffers(adminIDs: adminIDs))
        } else {
            return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }

    func deleteOfferPrivateParts(adminIDs: [String], publicKeys: [String]) -> AnyPublisher<Void, Error> {
        if !adminIDs.isEmpty {
            return request(endpoint: OffersRouter.deleteOfferPrivateParts(adminIDs: adminIDs, publicKeys: publicKeys))
        } else {
            return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }

    // MARK: Helper functions

    func getReceiverPublicKeys(friendLevel: ContactFriendLevel, groups: [ManagedGroup], includeUserPublicKey userPublicKey: String) -> AnyPublisher<PKsEnvelope, Error> {
        contactsService
            .getAllContacts(
                friendLevel: friendLevel,
                hasFacebookAccount: authenticationManager.facebookSecurityHeader != nil,
                pageLimit: Constants.pageMaxLimit
            )
            .flatMap { contactEnvelope -> AnyPublisher<PKsEnvelope, Never> in
                guard !groups.isEmpty else {
                    return Just(
                            PKsEnvelope(contacts: contactEnvelope, groups: [], userPublicKey: userPublicKey)
                        )
                        .eraseToAnyPublisher()
                }
                // If this dependency is defined in header, it would cause circular dependency
                @Inject var groupManager: GroupManagerType
                return groupManager
                    .getAllGroupMembers(groups: groups)
                    .catch { _ in Just([]) }
                    .map { groupEnvelopes in
                        PKsEnvelope(contacts: contactEnvelope, groups: groupEnvelopes, userPublicKey: userPublicKey)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func encryptOffer(offer: ManagedOffer, envelope: PKsEnvelope) -> AnyPublisher<OfferRequestPayload, Error> {
        guard let symmetricKey = offer.symmetricKey, let offerType = offer.type, let expiration = offer.expirationDate?.timeIntervalSince1970 else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        let privateParts = self
            .generateOfferPayloadPrivateParts(envelope: envelope, symmetricKey: symmetricKey)
            .flatMap(encryptOfferPayloadPrivateParts)

        let publicPart = self
            .encryptOfferPayloadPublic(offer: offer, symmetricKey: symmetricKey)

        let payload = Publishers.Zip(publicPart, privateParts)
            .map { (publicPart, privateParts) -> OfferRequestPayload in
                OfferRequestPayload(
                    offerType: offerType.rawValue,
                    expiration: Int(expiration),
                    payloadPublic: publicPart,
                    offerPrivateList: privateParts
                )
            }
            .eraseToAnyPublisher()

        return payload
    }

    func generateOfferPayloadPrivateParts(envelope: PKsEnvelope, symmetricKey: String) -> AnyPublisher<[OfferPayloadPrivateWrapper], Never> {
        let allPublicKeys = envelope.allPublicKeys
        let privateParts = envelope.generatePrivateParts(symmetricKey: symmetricKey)
        let commonFriends = contactsService
            .getCommonFriends(publicKeys: allPublicKeys)
            .catch { _ in Just([:]) }
            .map { commonFriendsMap in
                privateParts.map { part in
                    var part = part
                    part.payloadPrivate.commonFriends = commonFriendsMap[part.userPublicKey] ?? []
                    return part
                }
            }
            .eraseToAnyPublisher()
        return commonFriends
    }

    func encryptOfferPayloadPrivateParts(privateParts: [OfferPayloadPrivateWrapper]) -> AnyPublisher<[OfferPayloadPrivateWrapperEncrypted], Error> {
        encryptionService.encryptOfferPayload(privateParts: privateParts)
    }

    func encryptOfferPayloadPublic(offer: ManagedOffer, symmetricKey: String) -> AnyPublisher<String, Error> {
        encryptionService.encryptOfferPayloadPublic(offer: offer, symmetricKey: symmetricKey)
    }
}
