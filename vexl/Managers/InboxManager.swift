//
//  InboxManager.swift
//  vexl
//
//  Created by Diego Espinoza on 5/06/22.
//

import Foundation
import Combine

private typealias KeyAndChallenge = (key: String, challenge: String)
private typealias KeyAndSignature = (key: String, signature: String)
private typealias KeyAndMessages = (key: String, messages: [ChatMessage])
private typealias KeyAndParsedMessages = (key: String, messages: [ParsedChatMessage])

protocol InboxManagerType {
    var isSyncing: AnyPublisher<Bool, Never> { get }
    var completedSyncing: AnyPublisher<[ChatMessage], Never> { get }

    func syncInbox() -> AnyPublisher<Void, Error>
}

final class InboxManager: InboxManagerType {

    @Inject var userSecurity: UserSecurityType
    @Inject var cryptoService: CryptoServiceType
    @Inject var chatService: ChatServiceType
    @Inject var localStorageService: LocalStorageServiceType

    private var _isSyncing = CurrentValueSubject<Bool, Never>(false)
    private var _completedSyncing = PassthroughSubject<[ChatMessage], Never>()

    var isSyncing: AnyPublisher<Bool, Never> {
        _isSyncing.eraseToAnyPublisher()
    }

    var completedSyncing: AnyPublisher<[ChatMessage], Never> {
        _completedSyncing.eraseToAnyPublisher()
    }

    func syncInbox() -> AnyPublisher<Void, Error> {
        do {
            let createdInboxes = try localStorageService.getInboxes(ofType: .created)
            let requestedInboxes = try localStorageService.getInboxes(ofType: .requested)
            let inboxes = createdInboxes + requestedInboxes

            let challenges = inboxes.publisher
                .withUnretained(self)
                .flatMap { owner, inbox -> AnyPublisher<KeyAndChallenge, Error> in
                    owner.requestChallenge(publicKey: inbox.publicKey)
                }

            let signature = challenges
                .flatMapLatest(with: self) { owner, keyAndChallenge -> AnyPublisher<KeyAndSignature, Error> in
                    owner.signChallenge(keys: owner.userSecurity.userKeys, keyAndChallenge: keyAndChallenge)
                }

            let pullChat = signature
                .flatMapLatest(with: self) { owner, keyAndSignature -> AnyPublisher<KeyAndMessages, Error> in
                    owner.pullInboxMessage(keyAndSignature: keyAndSignature)
                }

            let saveMessages = pullChat
                .withUnretained(self)
                .flatMap { owner, keyAndMessages -> AnyPublisher<KeyAndParsedMessages, Error> in
                    owner.saveFetchedMessages(keyAndMessages: keyAndMessages)
                }

            let deleteChat = saveMessages
                .withUnretained(self)
                .flatMap { owner, keyAndMessages -> AnyPublisher<[ParsedChatMessage], Error> in
                    owner.deleteMessages(keyAndMessages: keyAndMessages)
                }

            // 1. Notify isSync(false)
            // 2. Notify completedSync([ParsedChatMessage])
            // 3. Update Inbox with ParsedChatMessage per offer + from - check if 

            return deleteChat
                .collect()
                .asVoid()
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: ChatError.storageEmpty)
                .eraseToAnyPublisher()
        }
    }

    private func requestChallenge(publicKey: String) -> AnyPublisher<KeyAndChallenge, Error> {
        chatService.requestChallenge(publicKey: publicKey)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure = completion { self?._isSyncing.send(false) }
            })
            .map { KeyAndChallenge(key: publicKey, challenge: $0.challenge) }
            .eraseToAnyPublisher()
    }

    private func signChallenge(keys: ECCKeys, keyAndChallenge: KeyAndChallenge) -> AnyPublisher<KeyAndSignature, Error> {
        cryptoService.signECDSA(keys: keys, message: keyAndChallenge.challenge)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure = completion { self?._isSyncing.send(false) }
            })
            .map { KeyAndSignature(key: keyAndChallenge.key, signature: $0) }
            .eraseToAnyPublisher()
    }

    private func pullInboxMessage(keyAndSignature: KeyAndSignature) -> AnyPublisher<KeyAndMessages, Error> {
        chatService.pullInboxMessages(publicKey: keyAndSignature.key, signature: keyAndSignature.signature)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure = completion { self?._isSyncing.send(false) }
            })
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
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure = completion { self?._isSyncing.send(false) }
            })
            .map { _ in keyAndMessages.messages }
            .eraseToAnyPublisher()
    }
}
