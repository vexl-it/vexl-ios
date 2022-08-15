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
    var didDeleteChat: AnyPublisher<Void, Never> { get }

    func syncInboxes()
    func userRequestedSync()

    func syncInbox(with publicKey: String)
}

final class InboxManager: InboxManagerType {
    @Inject var inboxRepository: InboxRepositoryType
    @Inject var cryptoService: CryptoServiceType
    @Inject var chatService: ChatServiceType
    @Inject var userRepository: UserRepositoryType

    var didFinishSyncing: AnyPublisher<Void, Never> {
        _didFinishSyncing.eraseToAnyPublisher()
    }

    var didDeleteChat: AnyPublisher<Void, Never> {
        _didDeleteChat.eraseToAnyPublisher()
    }

    private var _didDeleteChat: PassthroughSubject<Void, Never> = .init()
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

    func syncInbox(with publicKey: String) {
        inboxRepository
            .getInbox(with: publicKey)
            .filterNil()
            .withUnretained(self)
            .flatMap { owner, inbox in
                owner.syncInbox(inbox)
            }
            .sink()
            .store(in: cancelBag)
    }

    private func syncInbox(_ inbox: ManagedInbox) -> AnyPublisher<Result<[MessagePayload], Error>, Error> {
        guard let inboxKeys = inbox.keyPair?.keys else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }

        let challenge = chatService.requestChallenge(publicKey: inboxKeys.publicKey)
            .map { $0.challenge }
            .eraseToAnyPublisher()

        let signature = challenge
            .flatMapLatest { [cryptoService] challenge in
                cryptoService.signECDSA(keys: inboxKeys, message: challenge)
            }
            .eraseToAnyPublisher()

        let encryptedMessages = signature
            .flatMapLatest { [chatService] signature -> AnyPublisher<[EncryptedChatMessage], Error> in
                chatService.pullInboxMessages(publicKey: inboxKeys.publicKey, signature: signature)
                    .map(\.messages)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let messagePayloads = encryptedMessages
            .filter { !$0.isEmpty }
            .flatMap { messages in
                messages.publisher
                    .compactMap { MessagePayload(chatMessage: $0, key: inboxKeys, inboxPublicKey: inboxKeys.publicKey) }
                    .collect()
            }
            .eraseToAnyPublisher()

        let deleteMessages = messagePayloads
            .flatMap { [inboxRepository] payloads -> AnyPublisher<[MessagePayload], Error> in
                inboxRepository
                    .deleteChats(recevedPayloads: payloads, inbox: inbox)
                    .withUnretained(self)
                    .handleEvents(receiveOutput: { owner, delete in
                        if delete {
                            owner._didDeleteChat.send(())
                        }
                    })
                    .map { _ -> [MessagePayload] in payloads }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let saveMessages: AnyPublisher<[MessagePayload], Error> = deleteMessages
            .flatMap { [inboxRepository] payloads -> AnyPublisher<[MessagePayload], Error> in
                inboxRepository
                    .createOrUpdateChats(receivedPayloads: payloads, inbox: inbox)
                    .map { payloads }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let deleteChat = saveMessages
            .flatMap { [chatService] payloads in
                chatService.deleteInboxMessages(publicKey: inboxKeys.publicKey)
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

    private func deleteMessages(inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        chatService.deleteInboxMessages(publicKey: inboxPublicKey)
            .eraseToAnyPublisher()
    }
}
