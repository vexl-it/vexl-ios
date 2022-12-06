//
//  InboxManager.swift
//  vexl
//
//  Created by Diego Espinoza on 5/06/22.
//

import Foundation
import Combine
import Cleevio

protocol InboxManagerType {
    var didFinishSyncing: AnyPublisher<Void, Never> { get }

    func syncInboxes()
    func userRequestedSync()

    func syncInbox(with publicKey: String, completionHandler: ((Error?) -> Void)?)
    func updateNotificationToken(token: String) -> AnyPublisher<Void, Error>
}

extension InboxManagerType {
    func syncInbox(with publicKey: String) {
        syncInbox(with: publicKey, completionHandler: nil)
    }
}

final class InboxManager: InboxManagerType {
    @Inject var inboxRepository: InboxRepositoryType
    @Inject var cryptoService: CryptoServiceType
    @Inject var chatService: ChatServiceType
    @Inject var userRepository: UserRepositoryType

    var didFinishSyncing: AnyPublisher<Void, Never> {
        _didFinishSyncing.eraseToAnyPublisher()
    }

    private var _didFinishSyncing: PassthroughSubject<Void, Never> = .init()
    private var isRefreshingInboxes = false
    private var activity: Activity = .init()
    private var cancelBag = CancelBag()

    init() {
        activity.indicator
            .loading
            .withUnretained(self)
            .filter { !$0.1 && $0.0.isRefreshingInboxes }
            .sink { owner, _ in
                owner.isRefreshingInboxes = false
                owner._didFinishSyncing.send(())
            }
            .store(in: cancelBag)
    }

    func userRequestedSync() {
        if !isRefreshingInboxes {
            isRefreshingInboxes = true
            syncInboxes()
        }
    }

    func syncInboxes() {
        let userOffers = userRepository.user?.offers?.allObjects as? [ManagedOffer] ?? []
        let userOfferInboxes = userOffers.compactMap(\.inbox)

        let userInbox = userRepository.user?.profile?.keyPair?.inbox
        var inboxes = userOfferInboxes + [userInbox].compactMap { $0 }
        inboxes = inboxes.filter { $0.syncItem == nil }

        let inboxPublishers = inboxes.map { inbox in
            self.syncInbox(inbox)
                .track(activity: activity)
                .materialize()
                .compactMap(\.value)
        }

        Publishers.MergeMany(inboxPublishers)
            .collect()
            .sink()
            .store(in: cancelBag)
    }

    func syncInbox(with publicKey: String, completionHandler: ((Error?) -> Void)?) {
        inboxRepository
            .getInbox(with: publicKey)
            .compactMap {
                if $0 == nil {
                    completionHandler?(nil)
                }
                return $0
            }
            .withUnretained(self)
            .flatMap { owner, inbox in
                owner.syncInbox(inbox)
            }
            .asVoid()
            .handleEvents(
                receiveOutput: {
                    completionHandler?(nil)
                },
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        completionHandler?(error)
                    case .finished:
                        break
                    }
                }
            )
            .sink()
            .store(in: cancelBag)
    }

    private func syncInbox(_ inbox: ManagedInbox) -> AnyPublisher<Result<[MessagePayload], Error>, Error> {
        guard let inboxKeys = inbox.keyPair?.keys else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }

        let encryptedMessages = chatService.pullInboxMessages(publicKey: inboxKeys.publicKey, eccKeys: inboxKeys)
            .map(\.messages)
            .eraseToAnyPublisher()

        let messagePayloads = encryptedMessages
            .filter { !$0.isEmpty }
            .flatMap { messages in
                messages.publisher
                    .compactMap { message -> (publicID: Int, payload: MessagePayload)? in
                        guard let payload = MessagePayload(chatMessage: message, key: inboxKeys, inboxPublicKey: inboxKeys.publicKey) else {
                            return nil
                        }
                        return (message.id, payload)
                    }
                    .collect()
            }
            .eraseToAnyPublisher()

        let deleteMessages = messagePayloads
            .flatMap { [inboxRepository] payloads -> AnyPublisher<[(publicID: Int, payload: MessagePayload)], Error> in
                inboxRepository
                    .setInboxChatsUserLeft(receivedPayloads: payloads.map(\.payload), inbox: inbox)
                    .withUnretained(self)
                    .map { _ -> [(publicID: Int, payload: MessagePayload)] in payloads }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let saveMessages: AnyPublisher<[MessagePayload], Error> = deleteMessages
            .flatMap { [inboxRepository] payloads -> AnyPublisher<[MessagePayload], Error> in
                inboxRepository
                    .createOrUpdateChats(receivedPayloads: payloads, inbox: inbox)
                    .map { payloads.map(\.payload) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let deleteChat = saveMessages
            .flatMap { [chatService] payloads in
                chatService.deleteInboxMessages(publicKey: inboxKeys.publicKey, eccKeys: inboxKeys)
                    .map { payloads }
            }
            .eraseToAnyPublisher()

        return deleteChat
            .map { Result.success($0) }
            .catch { _ in
                Just(Result.failure(InboxError.inboxSyncFailed))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func updateNotificationToken(token: String) -> AnyPublisher<Void, Error> {
        userRepository
            .getInboxes()
            .compactMap { inbox -> (keys: ECCKeys, token: String)? in
                guard let inboxKeys = inbox.keyPair?.keys else {
                    return nil
                }
                return (keys: inboxKeys, token: token)
            }
            .publisher
            .flatMap(maxPublishers: .max(1), chatService.updateInbox)
            .collect()
            .asVoid()
            .eraseToAnyPublisher()
    }
}
