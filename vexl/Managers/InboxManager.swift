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
    var inboxMessages: AnyPublisher<[ParsedChatMessage], Error> { get }
    var isSyncing: AnyPublisher<Bool, Never> { get }
    var completedSyncing: AnyPublisher<Result<[ParsedChatMessage], InboxError>, Never> { get }

    func syncInboxes()
}

final class InboxManager: InboxManagerType {

    @Inject var userSecurity: UserSecurityType
    @Inject var cryptoService: CryptoServiceType
    @Inject var chatService: ChatServiceType
    @Inject var localStorageService: LocalStorageServiceType

    var isSyncing: AnyPublisher<Bool, Never> {
        _syncActivity.loading
    }

    var completedSyncing: AnyPublisher<Result<[ParsedChatMessage], InboxError>, Never> {
        _completedSyncing.eraseToAnyPublisher()
    }

    var inboxMessages: AnyPublisher<[ParsedChatMessage], Error> {
        _inboxMessages.eraseToAnyPublisher()
    }

    private var _completedSyncing = PassthroughSubject<Result<[ParsedChatMessage], InboxError>, Never>()
    private var _syncActivity = ActivityIndicator()
    private var _inboxMessages = CurrentValueSubject<[ParsedChatMessage], Error>([])
    private var cancelBag = CancelBag()

    func syncInboxes() {

        guard let inboxes = try? localStorageService.getInboxes(ofType: .created) else {
            return
        }

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

    private func syncInbox(_ inbox: ChatInbox) -> AnyPublisher<Result<[ParsedChatMessage], Error>, Error> {

        let challenge = requestChallenge(key: inbox.key)
            .subscribe(on: DispatchQueue.global(qos: .background))

        let signature = challenge
            .flatMapLatest(with: self) { owner, challenge -> AnyPublisher<String, Error> in
                owner.signChallenge(keys: inbox.key, challenge: challenge)
            }

        let pullChat = signature
            .flatMapLatest(with: self) { owner, signature -> AnyPublisher<[EncryptedChatMessage], Error> in
                owner.pullInboxMessage(inboxPublicKey: inbox.publicKey, signature: signature)
            }

        let saveMessages = pullChat
            .flatMapLatest(with: self) { owner, encryptedMessages -> AnyPublisher<[ParsedChatMessage], Error> in
                owner.saveFetchedMessages(encryptedMessages, inboxKeys: inbox.key)
            }

        let deleteChat = saveMessages
            .flatMapLatest(with: self) { owner, parsedMessages -> AnyPublisher<[ParsedChatMessage], Error> in
                owner.deleteMessages(inboxPublicKey: inbox.publicKey)
                    .map { parsedMessages }
                    .eraseToAnyPublisher()
            }

        return deleteChat
            .map { .success($0) }
            .catch { _ in
                Just(.failure(InboxError.inboxSyncFailed)).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Methods for syncing up the app messages with the server

    private func requestChallenge(key: ECCKeys) -> AnyPublisher<String, Error> {
        chatService.requestChallenge(publicKey: key.publicKey)
            .map { $0.challenge }
            .eraseToAnyPublisher()
    }

    private func signChallenge(keys: ECCKeys, challenge: String) -> AnyPublisher<String, Error> {
        cryptoService.signECDSA(keys: keys, message: challenge)
            .eraseToAnyPublisher()
    }

    private func pullInboxMessage(inboxPublicKey: String, signature: String) -> AnyPublisher<[EncryptedChatMessage], Error> {
        chatService.pullInboxMessages(publicKey: inboxPublicKey, signature: signature)
            .map(\.messages)
            .eraseToAnyPublisher()
    }

    private func saveFetchedMessages(_ messages: [EncryptedChatMessage],
                                     inboxKeys: ECCKeys) -> AnyPublisher<[ParsedChatMessage], Error> {
        parseMessages(messages, key: inboxKeys, inboxPublicKey: inboxKeys.publicKey)
            .flatMapLatest(with: self) { owner, messages -> AnyPublisher<[ParsedChatMessage], Error> in
                owner.chatService.saveFetchedMessages(messages, inboxPublicKey: inboxKeys.publicKey)
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

    private func updateInboxMessages() -> AnyPublisher<Void, Error> {
        chatService.getInboxMessages()
            .withUnretained(self)
            .subscribe(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { owner, messages in
                owner._inboxMessages.send(messages)
            })
            .asVoid()
            .eraseToAnyPublisher()
    }
}
