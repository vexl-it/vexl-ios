//
//  InboxManager.swift
//  vexl
//
//  Created by Diego Espinoza on 5/06/22.
//

import Foundation
import Combine
import Cleevio

private typealias KeyAndChallenge = (key: String, challenge: String)
private typealias KeyAndSignature = (key: String, signature: String)
private typealias KeyAndMessages = (key: String, messages: [ChatMessage])
private typealias KeyAndParsedMessages = (key: String, messages: [ParsedChatMessage])

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

    private func syncInbox(_ inbox: UserInbox) -> AnyPublisher<Result<[ParsedChatMessage], Error>, Error> {
        let challenge = requestChallenge(publicKey: inbox.publicKey)
            .subscribe(on: DispatchQueue.global(qos: .background))

        let signature = challenge
            .flatMapLatest(with: self) { owner, keyAndChallenge -> AnyPublisher<KeyAndSignature, Error> in
                owner.signChallenge(keys: owner.userSecurity.userKeys, keyAndChallenge: keyAndChallenge)
            }

        let pullChat = signature
            .flatMapLatest(with: self) { owner, keyAndSignature -> AnyPublisher<KeyAndMessages, Error> in
                owner.pullInboxMessage(keyAndSignature: keyAndSignature)
            }

        // Store/Update messages in the Latest Message and Pending Requests Table
        // - check if depending on the type it will always go 
        // - if not first then get last. Logic should be in ChatService.

        let saveMessages = pullChat
            .flatMapLatest(with: self) { owner, keyAndMessages -> AnyPublisher<KeyAndParsedMessages, Error> in
                owner.saveFetchedMessages(keyAndMessages: keyAndMessages)
            }

        let deleteChat = saveMessages
            .flatMapLatest(with: self) { owner, keyAndMessages -> AnyPublisher<[ParsedChatMessage], Error> in
                owner.deleteMessages(keyAndMessages: keyAndMessages)
            }

        return deleteChat
            .map { .success($0) }
            .catch { _ in
                Just(.failure(InboxError.inboxSyncFailed)).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func syncInboxes() {
        guard let createdInboxes = try? localStorageService.getInboxes(ofType: .created),
              let requestedInboxes = try? localStorageService.getInboxes(ofType: .requested) else {
                  return
              }

        let inboxes = createdInboxes + requestedInboxes
        let inboxPublishers = inboxes.map { inbox in
            self.syncInbox(inbox)
        }

        let syncInboxes = Publishers.MergeMany(inboxPublishers)
            .collect()

        let updateInboxMessages = syncInboxes
            .flatMapLatest(with: self) { owner, results -> AnyPublisher<[Result<[ParsedChatMessage], Error>], Error> in

                // TODO: - Makes sense to have this in the queue? or should it be just a call and
                // let it update after it finishes / dont worrying about it

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

    // MARK: - Methods for syncing up the app messages with the server

    private func requestChallenge(publicKey: String) -> AnyPublisher<KeyAndChallenge, Error> {
        chatService.requestChallenge(publicKey: publicKey)
            .map { KeyAndChallenge(key: publicKey, challenge: $0.challenge) }
            .eraseToAnyPublisher()
    }

    private func signChallenge(keys: ECCKeys, keyAndChallenge: KeyAndChallenge) -> AnyPublisher<KeyAndSignature, Error> {
        cryptoService.signECDSA(keys: keys, message: keyAndChallenge.challenge)
            .map { KeyAndSignature(key: keyAndChallenge.key, signature: $0) }
            .eraseToAnyPublisher()
    }

    private func pullInboxMessage(keyAndSignature: KeyAndSignature) -> AnyPublisher<KeyAndMessages, Error> {
        chatService.pullInboxMessages(publicKey: keyAndSignature.key, signature: keyAndSignature.signature)
            .map { KeyAndMessages(key: keyAndSignature.key, messages: $0) }
            .eraseToAnyPublisher()
    }

    private func saveFetchedMessages(keyAndMessages: KeyAndMessages) -> AnyPublisher<KeyAndParsedMessages, Error> {
        chatService.saveFetchedMessages(keyAndMessages.messages)
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<[ParsedChatMessage], Error> in
                owner.parseMessages(keyAndMessages.messages)
            }
            .map { KeyAndParsedMessages(key: keyAndMessages.key, messages: $0) }
            .eraseToAnyPublisher()
    }

    private func parseMessages(_ messages: [ChatMessage]) -> AnyPublisher<[ParsedChatMessage], Error> {
        messages.publisher
            .compactMap { ParsedChatMessage(chatMessage: $0) }
            .collect()
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func deleteMessages(keyAndMessages: KeyAndParsedMessages) -> AnyPublisher<[ParsedChatMessage], Error> {
        chatService.deleteInboxMessages(publicKey: keyAndMessages.key)
            .map { _ in keyAndMessages.messages }
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
