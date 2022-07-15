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

    @Fetched(contextType: .background)
    private var queue: [ManagedSyncItem]

    private var cancelBag: CancelBag = .init()
    private var runningItems: [NSManagedObjectID: SyncQueueItemStatus] = [:]

    init() {
        setupMonitoring()
    }

    private func setupMonitoring() {
        let isLogged = authenticationManager.isUserLoggedInPublisher
            .print("[SyncQueue] isLogged")

        let isConnected = networkManager.isConnectedPublisher
            .print("[SyncQueue] isConnected")

        let canSync = Publishers.CombineLatest(isLogged, isConnected)
            .map { isLogged, isConnected in isLogged && isConnected }
            .print("[SyncQueue] canSync")

        let persistentQueue = $queue.publisher
            .filter { $0.event == .insert }
            .print("[SyncQueue] persistentQueue")
            .map(\.objects)

        let queue = Publishers.CombineLatest(canSync, persistentQueue)
            .filter(\.0)
            .map(\.1)
            .withUnretained(self)
            .map { $0.0.filterNewItems(items: $0.1) }
            .print("[SyncQueue] newQueueItems")
            .filter { !$0.isEmpty }

        queue
            .withUnretained(self)
            .flatMap { owner, queue -> AnyPublisher<Void, Never> in
                queue
                    .publisher
                    .withUnretained(owner)
                    .flatMap { owner, item in
                        owner
                            .doAction(item: item)
                            .materialize()
                            .compactMap(\.value)
                    }
                    .collect()
                    .print("[SyncQueue] items collected")
                    .materialize()
                    .compactMap(\.value)
                    .asVoid()
                    .eraseToAnyPublisher()
            }
            .print("[SyncQueue] finish")
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

    private func doAction(item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        if let offer = item.offer {
            return uploadOffer(offer: offer, item: item)
        } else if let inbox = item.inbox {
            return uploadInbox(inbox: inbox, item: item)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func uploadOffer(offer: ManagedOffer, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {

    }

    private func uploadInbox(inbox: ManagedInbox, item: ManagedSyncItem) -> AnyPublisher<Void, Error> {
        
    }
}
