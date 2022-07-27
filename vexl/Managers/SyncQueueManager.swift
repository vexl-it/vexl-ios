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

protocol SyncQueueManagerType {}

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

    @Fetched private var queue: [ManagedSyncItem]

    private var cancelBag: CancelBag = .init()
    private var runningItems: [NSManagedObjectID: SyncQueueItemStatus] = [:]

    init() {
        setupMonitoring()
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
            case .insert:
                return createOffer(offer: offer, item: item)
            case .update:
                return updateOffer(offer: offer, item: item)
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
              let expiration = offer.expirationDate?.timeIntervalSince1970,
              let userPublicKey = userRepository.user?.profile?.keyPair?.publicKey
        else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        let createOffer = offerService
            .createOffer(offer: offer, userPublicKey: userPublicKey, fiendLevel: friendLevel.convertToContactFriendLevel, expiration: expiration)

        let updatePersistence = createOffer
            .flatMapLatest(with: self) { owner, offerPayload -> AnyPublisher<Void, Error> in
                owner.persistence
                    .update(context: owner.$queue.context) { _ in
                        offer.id = offerPayload.offerId
                        return offer
                    }
                    .asVoid()
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
        guard let friendLevel = offer.friendLevel,
              let expiration = offer.expirationDate?.timeIntervalSince1970,
              let userPublicKey = userRepository.user?.profile?.keyPair?.publicKey
        else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        let createOffer = offerService
            .createOffer(offer: offer, userPublicKey: userPublicKey, fiendLevel: friendLevel.convertToContactFriendLevel, expiration: expiration)

        let updatePersistence = createOffer
            .flatMapLatest(with: self) { owner, offerPayload -> AnyPublisher<Void, Error> in
                owner.persistence
                    .update(context: owner.$queue.context) { _ in
                        offer.id = offerPayload.offerId
                        return offer
                    }
                    .asVoid()
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

    private func uploadInbox(inbox: ManagedInbox, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        guard let publicKey = inbox.keyPair?.publicKey else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }

        let context = $queue.context

        return chatService
            .createInbox(
                publicKey: publicKey,
                pushToken: Constants.pushNotificationToken
            )
            .flatMap { [persistence] _ -> AnyPublisher<Void, Error> in
                persistence.delete(context: context, object: item)
            }
            .eraseToAnyPublisher()
    }
}
