//
//  SyncQueueManager.swift
//  vexl
//
//  Created by Adam Salih on 10.07.2022.
//

import Foundation
import CoreData
import Combine
import Network
import Cleevio

protocol SyncQueueManagerType {
    func add<T: NSManagedObject>(type: SyncQueueItemType, object: T, publicKeys: [String]?) -> AnyPublisher<Void, Error>
}

enum SyncQueueItemStatus {
    case dispatched
    case finished
    case error
}

final class SyncQueueManager: SyncQueueManagerType {

    @Inject private var networkManager: NetworkManagerType
    @Inject private var authenticationManager: AuthenticationManagerType
    @Inject private var persistence: PersistenceStoreManagerType
    @Inject private var userRepository: UserRepositoryType
    @Inject private var offerService: OfferServiceType
    @Inject private var chatService: ChatServiceType
    @Inject private var notificationManager: NotificationManagerType

    @Fetched private var queue: [ManagedSyncItem]

    private var cancelBag: CancelBag = .init()
    private var runningItems: [NSManagedObjectID: SyncQueueItemStatus] = [:]

    init() {
        setupMonitoring()
    }

    func add<T: NSManagedObject>(type: SyncQueueItemType, object: T, publicKeys: [String]?) -> AnyPublisher<Void, Error> {
        persistence.insert(context: $queue.context) { context -> ManagedSyncItem in
            let item = ManagedSyncItem(context: context)
            item.type = type
            switch object {
            case let offer as ManagedOffer:
                item.offer = offer
            case let inbox as ManagedInbox:
                item.inbox = inbox
            default:
                item.type = nil
            }
            return item
        }
        .asVoid()
        .eraseToAnyPublisher()
    }

    private func setupMonitoring() {
        let isLogged = authenticationManager.isUserLoggedInPublisher
        let isConnected = networkManager.isConnectedPublisher

        let canSync = Publishers.CombineLatest(isLogged, isConnected)
            .map { isLogged, isConnected in isLogged && isConnected }
            .print("[SyncQueue] CanSync")

        let persistentQueue = $queue.publisher
            .filter { $0.event == .insert }
            .map(\.objects)

        let queue = Publishers.CombineLatest(canSync, persistentQueue)
            .filter(\.0)
            .map(\.1)
            .withUnretained(self)
            .map { $0.0.filterNewItems(items: $0.1) }
            .filter { !$0.isEmpty }
            .share()

        queue
            .map(\.count)
            .print("[SyncQueue] Items to sync")
            .sink()
            .store(in: cancelBag)

        queue
            .withUnretained(self)
            .flatMap { owner, queue -> AnyPublisher<Void, Never> in
                queue
                    .publisher
                    .withUnretained(owner)
                    .flatMap { owner, item in
                        owner
                            .dispatch(item: item)
                            .materialize()
                            .compactMap(\.value)
                    }
                    .collect()
                    .materialize()
                    .compactMap(\.value)
                    .asVoid()
                    .eraseToAnyPublisher()
            }
            .sink()
            .store(in: cancelBag)
    }

    private func filterNewItems(items: [ManagedSyncItem]) -> [ManagedSyncItem] {
        let newItems = items.filter { item in
            switch runningItems[item.objectID] {
            case .dispatched, .finished:
                return false
            case .error, .none:
                return true
            }
        }

        newItems
            .forEach { runningItems[$0.objectID] = .dispatched }

        return newItems
    }

    private func dispatch(item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        if let offer = item.offer {
            switch item.type {
            case .offerCreate:
                return createOffer(offer: offer, item: item)
            case .offerUpdate:
                return updateOffer(offer: offer, item: item)
            case .offerEncryptionUpdate:
                return encryptOfferForPublicKeys(offer: offer, item: item)
            case .none:
                break
            }
        } else if let inbox = item.inbox {
            return uploadInbox(inbox: inbox, item: item)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func createOffer(offer: ManagedOffer, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        guard let receiverPublicKeys = item.publicKeys, let expiration = offer.expirationDate else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        let encryptedOffer = offerService
            .encryptOffer(offer: offer, publicKeys: receiverPublicKeys)

        let createOffer = encryptedOffer
            .flatMap { [offerService] payloads in
                offerService
                    .createOffer(expiration: expiration, offerPayloads: payloads)
            }

        let updatePersistence = createOffer
            .flatMapLatest(with: self) { owner, offerPayload -> AnyPublisher<Void, Error> in
                owner.persistence
                    .update(context: context) { _ in
                        if let offerID = offerPayload.offerId  {
                            offer.offerID = offerID
                        }
                        if let adminID = offerPayload.adminId  {
                            offer.adminID = adminID
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let removeSyncItem: AnyPublisher<Void, Error> = updatePersistence
            .flatMapLatest { [persistence] _ -> AnyPublisher<Void, Error> in
                persistence.delete(context: context, object: item)
            }
            .eraseToAnyPublisher()

        return removeSyncItem
    }

    private func updateOffer(offer: ManagedOffer, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        guard let adminID = offer.adminID, let receiverPublicKeys = item.publicKeys else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        return offerService.encryptOffer(offer: offer, publicKeys: receiverPublicKeys)
            .flatMap { [offerService] payloads in
                offerService.updateOffers(adminID: adminID, offerPayloads: payloads)
            }
            .flatMap { [persistence] _ -> AnyPublisher<Void, Error> in
                persistence.delete(context: context, object: item)
            }
            .eraseToAnyPublisher()
    }

    private func encryptOfferForPublicKeys(offer: ManagedOffer, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        guard let publicKeys = item.publicKeys,
              let userPublicKey = userRepository.user?.profile?.keyPair?.publicKey
        else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        return offerService
            .createNewPrivateParts(for: offer, userPublicKey: userPublicKey, receiverPublicKeys: publicKeys)
            .flatMapLatest { [persistence] _ -> AnyPublisher<Void, Error> in
                persistence.delete(context: context, object: item)
            }
            .eraseToAnyPublisher()
    }

    private func uploadInbox(inbox: ManagedInbox, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        guard let inboxKeyPair = inbox.keyPair,
              let inboxPubKey = inboxKeyPair.publicKey,
              let inboxPrivKey = inboxKeyPair.privateKey else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let inboxEccKeys = ECCKeys(pubKey: inboxPubKey, privKey: inboxPrivKey)
        let context = $queue.context

        let notificationToken = notificationManager
            .isRegisteredForNotifications
            .flatMap { [notificationManager] isRegistered -> AnyPublisher<String, Never> in
                guard isRegistered else {
                    return Just(Constants.fakePushNotificationToken)
                        .eraseToAnyPublisher()
                }
                return notificationManager.notificationToken
            }

        return notificationToken
            .flatMap { [chatService, persistence] token in
                chatService
                    .createInbox(
                        eccKeys: inboxEccKeys,
                        pushToken: token
                    )
                    .flatMap { _ -> AnyPublisher<Void, Error> in
                        persistence.delete(context: context, object: item)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
