//
//  OfferRepository.swift
//  vexl
//
//  Created by Adam Salih on 10.07.2022.
//
// swiftlint:disable function_parameter_count

import Foundation
import CoreData
import Combine

protocol OfferRepositoryType {
    func createOffer(
        offerId: String?,
        groupUuid: GroupUUID?,
        offerPublicKey: String?,
        offerPrivateKey: String?,
        currency: Currency?,
        minAmount: Double,
        maxAmount: Double,
        description: String?,
        feeState: OfferFeeOption?,
        feeAmount: Double,
        locationState: OfferTradeLocationOption,
        paymentMethods: [OfferPaymentMethodOption],
        btcNetworks: [OfferAdvancedBTCOption],
        friendLevel: OfferFriendDegree?,
        type: OfferType?,
        activePriceState: OfferTrigger?,
        activePriceValue: Double,
        active: Bool,
        expiration: Date?
    ) -> AnyPublisher<ManagedOffer, Error>

    func createOrUpdateOffer(offerPayloads: [OfferPayload]) -> AnyPublisher<[ManagedOffer], Error>

    func getOrder(with publicKey: String) -> AnyPublisher<ManagedOffer, Error>
}

class OfferRepository: OfferRepositoryType {

    @Inject private var persistence: PersistenceStoreManagerType
    @Inject private var userRepository: UserRepositoryType

    func createOffer(
        offerId: String?,
        groupUuid: GroupUUID?,
        offerPublicKey: String?,
        offerPrivateKey: String?,
        currency: Currency?,
        minAmount: Double,
        maxAmount: Double,
        description: String?,
        feeState: OfferFeeOption?,
        feeAmount: Double,
        locationState: OfferTradeLocationOption,
        paymentMethods: [OfferPaymentMethodOption],
        btcNetworks: [OfferAdvancedBTCOption],
        friendLevel: OfferFriendDegree?,
        type: OfferType?,
        activePriceState: OfferTrigger?,
        activePriceValue: Double,
        active: Bool,
        expiration: Date?
    ) -> AnyPublisher<ManagedOffer, Error> {
        persistence.insert(context: persistence.viewContext) { [userRepository] context in

            let offer = ManagedOffer(context: context)
            let inbox = ManagedInbox(context: context)
            let keyPair = ManagedKeyPair(context: context)

            keyPair.publicKey = offerPublicKey
            keyPair.privateKey = offerPrivateKey

            inbox.keyPair = keyPair
            inbox.syncItem = ManagedSyncItem(context: context)

            offer.inbox = inbox

            offer.id = offerId
            offer.groupUuid = groupUuid
            offer.currency = currency
            offer.minAmount = minAmount
            offer.maxAmount = maxAmount
            offer.offerDescription = description
            offer.feeState = feeState
            offer.feeAmount = feeAmount
            offer.locationState = locationState
            offer.paymentMethods = paymentMethods
            offer.btcNetworks = btcNetworks
            offer.friendLevel = friendLevel
            offer.type = type
            offer.activePriceState = activePriceState
            offer.activePriceValue = activePriceValue
            offer.active = active
            offer.expirationDate = expiration
            offer.createdAt = Date()
            offer.syncItem = ManagedSyncItem(context: context)
            offer.user = userRepository.getUser(for: context)

            return offer
        }
    }

    func createOrUpdateOffer(offerPayloads: [OfferPayload]) -> AnyPublisher<[ManagedOffer], Error> {
        let context = persistence.viewContext
        guard let userInboxID = userRepository.user?.profile?.keyPair?.inbox?.objectID,
              let userInbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: userInboxID),
              !offerPayloads.isEmpty else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }
        return persistence.insert(context: context) { [persistence] context in
            offerPayloads.compactMap { payload in
                let offers = persistence.loadSyncroniously(
                    type: ManagedOffer.self,
                    context: context,
                    predicate: NSPredicate(format: "id == '\(payload.offerId)'")
                )
                if let offer = offers.first {
                    _ = payload.decrypt(context: context, userInbox: userInbox, into: offer)
                    return nil
                }
                let offer = ManagedOffer(context: context)
                return payload.decrypt(context: context, userInbox: userInbox, into: offer)
            }
        }
    }

    func getOrder(with publicKey: String) -> AnyPublisher<ManagedOffer, Error> {
        persistence.load(
            type: ManagedKeyPair.self,
            context: persistence.viewContext,
            predicate: NSPredicate(format: "publicKey == '\(publicKey)'")
        )
        .map(\.first)
        .flatMap { keyPair -> AnyPublisher<ManagedOffer, Error> in
            // Received offers
            if let offer = keyPair?.offer {
                return Just(offer)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            // User offers
            if let offer = keyPair?.inbox?.offers?.first(where: { _ in true }) as? ManagedOffer {
                return Just(offer)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            return Fail(error: PersistenceError.notFound)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
