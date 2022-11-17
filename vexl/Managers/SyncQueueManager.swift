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
                    .flatMap(maxPublishers: .max(4)) { owner, item in
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
        guard let friendLevel = offer.friendLevel,
              let userPublicKey = userRepository.user?.profile?.keyPair?.publicKey
        else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        let pks = offerService.getReceiverPublicKeys(
            friendLevel: friendLevel.convertToContactFriendLevel,
            groups: [offer.group].compactMap { $0 },
            includeUserPublicKey: userPublicKey
        )

        let encryptedOffer = pks
            .flatMap { [offerService] envelope in
                offerService
                    .encryptOffer(offer: offer, envelope: envelope)
            }

        let createOffer = encryptedOffer
            .flatMap { [offerService] payload in
                offerService
                    .createOffer(offerPayload: payload)
            }

        let updatePersistence = createOffer
            .flatMapLatest(with: self) { owner, offerPayload -> AnyPublisher<Void, Error> in
                owner.persistence
                    .update(context: context) { _ in
                        offer.offerID = offerPayload.offerId
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
        guard let adminID = offer.adminID,
              let friendLevel = offer.friendLevel,
              let userPublicKey = userRepository.user?.profile?.keyPair?.publicKey
         else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        let pks = offerService.getReceiverPublicKeys(
            friendLevel: friendLevel.convertToContactFriendLevel,
            groups: [offer.group].compactMap { $0 },
            includeUserPublicKey: userPublicKey
        )

        let encryptedOffer = pks
            .flatMap { [offerService] envelope in
                offerService
                    .encryptOffer(offer: offer, envelope: envelope)
            }

        let updateOffer = encryptedOffer
            .flatMap { [offerService] payload in
                offerService.updateOffers(adminID: adminID, offerPayload: payload)
            }
            .flatMap { [persistence] _ -> AnyPublisher<Void, Error> in
                persistence.delete(context: context, object: item)
            }
            .eraseToAnyPublisher()

        return updateOffer
    }

    private func encryptOfferForPublicKeys(offer: ManagedOffer, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        guard let friendLevel = offer.friendLevel,
              let receiverPublicKeys = item.publicKeys,
              let userPublicKey = userRepository.user?.profile?.keyPair?.publicKey
        else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        let pks = offerService
            .getReceiverPublicKeys(
                friendLevel: friendLevel.convertToContactFriendLevel,
                groups: [offer.group].compactMap { $0 },
                includeUserPublicKey: userPublicKey
            )
            .map { truestedEnvelope in
                let receiverPKSet = Set(receiverPublicKeys)
                switch friendLevel {
                case .firstDegree:
                    let firstDegreeSet = Set(truestedEnvelope.contacts.firstDegree)
                    return Array(firstDegreeSet.intersection(receiverPKSet))
                case .secondDegree:
                    let secondDegreeSet = Set(truestedEnvelope.contacts.secondDegree)
                    return Array(secondDegreeSet.intersection(receiverPKSet))
                }
            }
            .map { pks in
                PKsEnvelope(
                    contacts: ContactPKsEnvelope(
                        firstDegree: friendLevel == .firstDegree ? pks : [],
                        secondDegree: friendLevel == .secondDegree ? pks : []
                    ),
                    groups: [],
                    userPublicKey: userPublicKey
                )
            }

        let encryptedOffer = pks
            .flatMap { [offerService] envelope in
                offerService.createNewPrivateParts(for: offer, envelope: envelope)
            }
            .flatMap { [persistence] _ -> AnyPublisher<Void, Error> in
                persistence.delete(context: context, object: item)
            }
            .eraseToAnyPublisher()

        return encryptedOffer
    }

    private func uploadInbox(inbox: ManagedInbox, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        guard let inboxKeys = inbox.keyPair?.keys else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

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
                        eccKeys: inboxKeys,
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
