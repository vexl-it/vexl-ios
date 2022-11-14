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
    func createOffer(keys: ECCKeys, locations: [OfferLocation], provider: @escaping (ManagedOffer) -> Void) -> AnyPublisher<ManagedOffer, Error>

    func update(offer: ManagedOffer, locations: [OfferLocation]?, provider: @escaping (ManagedOffer) -> Void) -> AnyPublisher<ManagedOffer, Error>

    func createOrUpdateOffer(offerPayloads: [OfferPayload]) -> AnyPublisher<[ManagedOffer], Error>

    func getOffer(with publicKey: String) -> AnyPublisher<ManagedOffer, Error>
    func getOffers(fromType type: OfferType?, fromSource source: OfferSource?) -> AnyPublisher<[ManagedOffer], Error>
    func getKnownOffers() -> AnyPublisher<[ManagedOffer], Error>
    func getUsersOffersWithoutSymetricKey() -> AnyPublisher<[ManagedOffer], Error>

    func sync(offers: [ManagedOffer], withPublicKeys: [String]) -> AnyPublisher<Void, Error>

    func flag(offer: ManagedOffer) -> AnyPublisher<Void, Error>

    func deleteOffers(offerIDs ids: [String]) -> AnyPublisher<Void, Error>
}

class OfferRepository: OfferRepositoryType {

    @Inject private var persistence: PersistenceStoreManagerType
    @Inject private var userRepository: UserRepositoryType

    func createOffer(
        keys: ECCKeys,
        locations: [OfferLocation],
        provider: @escaping (ManagedOffer) -> Void
    ) -> AnyPublisher<ManagedOffer, Error> {
        persistence.insert(context: persistence.viewContext) { [userRepository] context in
            let managedLocations = locations.map { location -> ManagedOfferLocation in
                let managedLocation = ManagedOfferLocation(context: context)
                managedLocation.lat = location.latitude
                managedLocation.lon = location.longitude
                managedLocation.city = location.city
                return managedLocation
            }

            let offer = ManagedOffer(context: context)
            let inbox = ManagedInbox(context: context)

            let keyPair = ManagedKeyPair(context: context)

            keyPair.publicKey = keys.publicKey
            keyPair.privateKey = keys.privateKey

            inbox.keyPair = keyPair
            inbox.syncItem = ManagedSyncItem(context: context)

            offer.inbox = inbox

            provider(offer)

            offer.user = userRepository.getUser(for: context)
            offer.locations = NSSet(array: managedLocations)

            return offer
        }
    }

    func update(
        offer: ManagedOffer,
        locations: [OfferLocation]?,
        provider: @escaping (ManagedOffer) -> Void
    ) -> AnyPublisher<ManagedOffer, Error> {
        persistence.update(context: persistence.viewContext) { context in
            if let locations = locations {
                let managedLocations = locations.map { location -> ManagedOfferLocation in
                    let managedLocation = ManagedOfferLocation(context: context)
                    managedLocation.lat = location.latitude
                    managedLocation.lon = location.longitude
                    managedLocation.city = location.city
                    return managedLocation
                }

                (offer.locations as? Set<ManagedOfferLocation>)?.forEach { location in
                    context.delete(location)
                }

                offer.locations = NSSet(array: managedLocations)
            }

            provider(offer)

            return offer
        }
    }

    func createOrUpdateOffer(offerPayloads: [OfferPayload]) -> AnyPublisher<[ManagedOffer], Error> {
        let context = persistence.viewContext
        guard let userKeys = userRepository.user?.profile?.keyPair?.keys,
              let userInboxID = userRepository.user?.profile?.keyPair?.inbox?.objectID,
              let userInbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: userInboxID) else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }
        guard !offerPayloads.isEmpty else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return persistence.insert(context: context) { [persistence] context in
            offerPayloads.compactMap { payload in
                guard let offerPublicKey = payload.decryptPublicKey(keyPair: userKeys) else {
                    return nil
                }
                let pks = persistence.loadSyncroniously(
                        type: ManagedKeyPair.self,
                        context: context,
                        predicate: NSPredicate(format: "publicKey == '\(offerPublicKey)'")
                    )
                if let localOfferKey = pks.first {
                    if let offer = localOfferKey.offer {
                        payload.decrypt(context: context, userInbox: userInbox, into: offer)
                        offer.isRemoved = false
                    }
                    return nil
                }
                let offer = ManagedOffer(context: context)
                return payload.decrypt(context: context, userInbox: userInbox, into: offer)
                    .flatMap { offer -> ManagedOffer in
                        let profile = ManagedProfile(context: context)

                        // creating new chat from requesting offer
                        profile.avatar = UIImage(named: R.image.profile.avatar.name)?.pngData() // TODO: generate random avatar
                        profile.generateRandomName()

                        offer.receiversPublicKey?.profile = profile

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

    func getUsersOffersWithoutSymetricKey() -> AnyPublisher<[ManagedOffer], Error> {
        persistence.load(
            type: ManagedOffer.self,
            context: persistence.viewContext,
            predicate: NSPredicate(format: "encryptedSymmetricKey == nil AND user != nil")
        )
    }

    func getKnownOffers() -> AnyPublisher<[ManagedOffer], Error> {
        persistence.load(type: ManagedOffer.self, context: persistence.viewContext, predicate: NSPredicate(format: "user == nil AND offerID != nil"))
    }

    func sync(offers unsafeOffers: [ManagedOffer], withPublicKeys publicKeys: [String]) -> AnyPublisher<Void, Error> {
        persistence.update(context: persistence.newEditContext()) { context in
            let offers = unsafeOffers
                .map(\.objectID)
                .map(context.object(with: ))
                .compactMap { $0 as? ManagedOffer }

            offers.forEach { offer in
                let item = ManagedSyncItem(context: context)
                item.publicKeys = publicKeys
                item.type = .offerEncryptionUpdate
                item.offer = offer
            }
        }
    }

    func flag(offer unsafeOffer: ManagedOffer) -> AnyPublisher<Void, Error> {
        persistence.update(context: persistence.viewContext) { context in
            let offer = context.object(with: unsafeOffer.objectID) as? ManagedOffer
            offer?.isFlagged = true
        }
    }

    func deleteOffers(offerIDs ids: [String]) -> AnyPublisher<Void, Error> {
        let context = persistence.viewContext

        let getOffers = persistence
            .load(
                type: ManagedOffer.self,
                context: context,
                predicate: NSPredicate(format: "%@ contains[cd] offerID", NSArray(array: ids))
            )
            .share()

        let deleteInboxes = getOffers
            .map { $0.compactMap(\.inbox?.keyPair?.publicKey) }
            .flatMap { [persistence] inboxesPublicKeys in
                persistence
                    .load(type: ManagedInbox.self,
                          context: context,
                          predicate: NSPredicate(format: "%@ contains[cd] keyPair.publicKey AND typeRawValue == nil",
                                                 NSArray(array: inboxesPublicKeys)))
            }
            .eraseToAnyPublisher()

        let deleteOffers = getOffers
            .flatMap { [persistence] offers -> AnyPublisher<Void, Error> in
                persistence.update(context: context) { _ in
                    offers.forEach { offer in
                        offer.isRemoved = true
                    }
                }
            }
            .eraseToAnyPublisher()

        return Publishers.Zip(deleteInboxes, deleteOffers)
            .asVoid()
            .eraseToAnyPublisher()
    }
}
