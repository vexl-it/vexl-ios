//
//  OfferRepository.swift
//  vexl
//
//  Created by Adam Salih on 10.07.2022.
//

import Foundation
import CoreData
import Combine
import UIKit

protocol OfferRepositoryType {
    func createOffer(keys: ECCKeys, provider: @escaping (ManagedOffer) -> Void) -> AnyPublisher<ManagedOffer, Error>

    func update(offer: ManagedOffer, provider: @escaping (ManagedOffer) -> Void) -> AnyPublisher<ManagedOffer, Error>

    func createOrUpdateOffer(offerPayloads: [OfferPayload]) -> AnyPublisher<[ManagedOffer], Error>

    func getOffer(with publicKey: String) -> AnyPublisher<ManagedOffer, Error>
    func getOffers(fromType type: OfferType?, fromSource source: OfferSource?) -> AnyPublisher<[ManagedOffer], Error>

    func deleteOffers(with ids: [String]) -> AnyPublisher<Void, Error>
}

class OfferRepository: OfferRepositoryType {

    @Inject private var persistence: PersistenceStoreManagerType
    @Inject private var userRepository: UserRepositoryType

    func createOffer(keys: ECCKeys, provider: @escaping (ManagedOffer) -> Void) -> AnyPublisher<ManagedOffer, Error> {
        persistence.insert(context: persistence.viewContext) { [userRepository] context in

            let offer = ManagedOffer(context: context)
            let inbox = ManagedInbox(context: context)
            let keyPair = ManagedKeyPair(context: context)

            keyPair.publicKey = keys.publicKey
            keyPair.privateKey = keys.privateKey

            inbox.keyPair = keyPair
            inbox.syncItem = ManagedSyncItem(context: context)

            offer.inbox = inbox

            provider(offer)

            offer.syncItem = ManagedSyncItem(context: context)
            offer.syncItem?.type = .insert
            offer.user = userRepository.getUser(for: context)

            return offer
        }
    }

    func update(offer: ManagedOffer, provider: @escaping (ManagedOffer) -> Void) -> AnyPublisher<ManagedOffer, Error> {
        persistence.update(context: persistence.viewContext) { context in
            provider(offer)

            if offer.syncItem != nil {
                offer.syncItem = ManagedSyncItem(context: context)
                offer.syncItem?.type = .update
            }

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
                    .flatMap { offer -> ManagedOffer in
                        let profile = ManagedProfile(context: context)

                        profile.avatar = UIImage(named: R.image.profile.avatar.name)?.pngData() // TODO: generate random avatar
                        profile.name = Constants.randomName // TODO: generate random name

                        offer.receiverPublicKey?.profile = profile

                        return offer
                    }
            }
        }
    }

    func getOffer(with publicKey: String) -> AnyPublisher<ManagedOffer, Error> {
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

    func getOffers(fromType type: OfferType?, fromSource source: OfferSource?) -> AnyPublisher<[ManagedOffer], Error> {
        var predicates: [NSPredicate] = []
        if let type = type {
            predicates.append(NSPredicate(format: "type == '\(type.rawValue)'"))
        }
        switch source {
        case .fetched:
            predicates.append(NSPredicate(format: "user == nil"))
        case .created:
            predicates.append(NSPredicate(format: "user != nil"))
        case .none:
            break
        }

        let predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return persistence.load(
            type: ManagedOffer.self,
            context: persistence.viewContext,
            predicate: predicate
        )
    }

    func deleteOffers(with ids: [String]) -> AnyPublisher<Void, Error> {
        let context = persistence.viewContext
        return persistence
            .load(
                type: ManagedOffer.self,
                context: context,
                predicate: NSPredicate(format: "%@ contains[cd] id", NSArray(array: ids))
            )
            .flatMap { [persistence] offers -> AnyPublisher<Void, Error> in
                persistence.delete(context: context, editor: { _ in offers })
            }
            .eraseToAnyPublisher()
    }
}
