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
    var currentInboxMessages: [ChatInboxMessage] { get }
    var inboxMessages: AnyPublisher<[ChatInboxMessage], Error> { get }
    var isSyncing: AnyPublisher<Bool, Never> { get }
    var completedSyncing: AnyPublisher<Result<[ParsedChatMessage], InboxError>, Never> { get }

    func syncInboxes()
    func updateInboxMessages() -> AnyPublisher<Void, Error>
}

final class InboxManager: InboxManagerType {
    @Inject var inboxRepository: InboxRepositoryType
    @Inject var cryptoService: CryptoServiceType
    @Inject var chatService: ChatServiceType
    @Inject var localStorageService: LocalStorageServiceType
    @Inject var userRepository: UserRepositoryType

    var isSyncing: AnyPublisher<Bool, Never> {
        _syncActivity.loading
    }

    var completedSyncing: AnyPublisher<Result<[ParsedChatMessage], InboxError>, Never> {
        _completedSyncing.eraseToAnyPublisher()
    }

    var inboxMessages: AnyPublisher<[ChatInboxMessage], Error> {
        _inboxMessages.eraseToAnyPublisher()
    }

    var currentInboxMessages: [ChatInboxMessage] {
        _inboxMessages.value
    }

    private var _completedSyncing = PassthroughSubject<Result<[ParsedChatMessage], InboxError>, Never>()
    private var _syncActivity = ActivityIndicator()
    private var _inboxMessages = CurrentValueSubject<[ChatInboxMessage], Error>([])
    private var cancelBag = CancelBag()

    func syncInboxes() {
        let userOfferInboxes = userRepository.user?.offers?.allObjects as? [ManagedInbox] ?? []
        let userInbox = userRepository.user?.profile?.keyPair?.inbox
        var inboxes = userOfferInboxes + [userInbox].compactMap { $0 }
        inboxes = inboxes.filter { $0.syncItem == nil }

        let inboxPublishers = inboxes.map { inbox in
            self.syncInbox(inbox)
        }

        let syncInboxes = Publishers.MergeMany(inboxPublishers)
            .collect()

        let updateInboxMessages = syncInboxes
            .flatMapLatest(with: self) { owner, results -> AnyPublisher<[Result<[ParsedChatMessage], Error>], Error> in
                owner.updateInboxMessages()
                    .map { results }
                    .eraseToAnyPublisher()
            }

        updateInboxMessages
            .trackActivity(_syncActivity)
            .withUnretained(self)
            .subscribe(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, results in

                let successfulResults = results.filter { if case .success = $0 { return true } else { return false } }

                if successfulResults.isEmpty {
                    owner._completedSyncing.send(.failure(.inboxesSyncFailed))
                } else {
                    let successfulParsedMessages = successfulResults.map { result -> [ParsedChatMessage] in
                        if case let .success(messages) = result { return messages }
                        return []
                    }

                    let fetchedParsedMessages = Array(successfulParsedMessages.joined())
                    owner._completedSyncing.send(.success(fetchedParsedMessages))
                }
            })
            .store(in: cancelBag)
    }

    private func syncInbox(_ inbox: ManagedInbox) -> AnyPublisher<Result<[ParsedChatMessage], Error>, Error> {
        guard let inboxKeys = inbox.keyPair?.keys else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }

        let challenge = chatService.requestChallenge(publicKey: inboxKeys.publicKey)
            .map { $0.challenge }
            .eraseToAnyPublisher()
            .subscribe(on: DispatchQueue.global(qos: .background))

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
            .flatMap { messages in
                messages.publisher
                    .compactMap { ParsedChatMessage(chatMessage: $0, key: inboxKeys, inboxPublicKey: inboxKeys.publicKey) }
                    .collect()
            }
            .eraseToAnyPublisher()

        let deleteMessages = messagePayloads
            .flatMap { [inboxRepository] payloads -> AnyPublisher<[ParsedChatMessage], Error> in
                inboxRepository
                    .deleteChats(recevedPayloads: payloads, inbox: inbox)
                    .map { payloads }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let saveMessages: AnyPublisher<[ParsedChatMessage], Error> = deleteMessages
            .flatMap { [inboxRepository] payloads -> AnyPublisher<[ParsedChatMessage], Error> in
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
                Just(Result.failure(InboxError.inboxSyncFailed)).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Methods for syncing up the app messages with the server

    private func saveFetchedMessages(_ messages: [EncryptedChatMessage],
                                     inboxKeys: ECCKeys) -> AnyPublisher<[ParsedChatMessage], Error> {
        parseMessages(messages, key: inboxKeys, inboxPublicKey: inboxKeys.publicKey)
            .flatMapLatest(with: self) { owner, messages -> AnyPublisher<[ParsedChatMessage], Error> in
                owner.chatService.saveParsedMessages(messages, inboxKeys: inboxKeys)
                    .map { messages }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func parseMessages(_ messages: [EncryptedChatMessage], key: ECCKeys, inboxPublicKey: String) -> AnyPublisher<[ParsedChatMessage], Error> {
        messages.publisher
            .compactMap { ParsedChatMessage(chatMessage: $0, key: key, inboxPublicKey: inboxPublicKey) }
            .collect()
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func deleteMessages(inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        chatService.deleteInboxMessages(publicKey: inboxPublicKey)
            .eraseToAnyPublisher()
    }

    func updateInboxMessages() -> AnyPublisher<Void, Error> {
        chatService.getStoredInboxMessages()
            .withUnretained(self)
            .subscribe(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { owner, chatInboxMessages in
                owner._inboxMessages.send(chatInboxMessages)
            })
            .asVoid()
            .eraseToAnyPublisher()
    }
}
