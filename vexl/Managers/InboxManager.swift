//
//  InboxManager.swift
//  vexl
//
//  Created by Diego Espinoza on 5/06/22.
//

import Foundation
import Combine

private typealias KeyAndSignature = (key: String, signature: String)
private typealias KeyAndMessages = (key: String, messages: [ChatMessage])

protocol InboxManagerType {
    func getStoredMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func syncInbox(publicKey: String) -> AnyPublisher<[ChatMessage], Error>
    func storeMessages(_ messages: [ChatMessage]) -> AnyPublisher<Void, Never>
}

final class InboxManager: InboxManagerType {

    @Inject var chatService: ChatServiceType
    @Inject var localStorageService: LocalStorageServiceType

    var messages: [ChatMessage] = []

    func getStoredMessages() -> AnyPublisher<[ParsedChatMessage], Error> {
        let messages = localStorageService.getMessages()
        return Future<[ParsedChatMessage], Error> { promise in
            promise(.success(messages))
        }
        .eraseToAnyPublisher()
    }

    func storeMessages(_ messages: [ChatMessage]) -> AnyPublisher<Void, Never> {
        messages.publisher
            .compactMap { chatMessage in
                ParsedChatMessage(chatMessage: chatMessage)
            }
            .collect()
            .handleEvents(receiveOutput: { parsedMessages in
                DictionaryDB.saveMessages(parsedMessages)
            })
            .asVoid()
            .eraseToAnyPublisher()
    }

    func syncInbox(publicKey: String) -> AnyPublisher<[ChatMessage], Error> {
        do {
            let createdInboxes = try localStorageService.getInboxes(ofType: .created)
            let requestedInboxes = try localStorageService.getInboxes(ofType: .requested)
            let inboxes = createdInboxes + requestedInboxes

            let challenges = inboxes.publisher
                .withUnretained(self)
                .flatMap { owner, inbox -> AnyPublisher<KeyAndSignature, Error> in
                    owner.chatService.requestChallenge(publicKey: inbox.publicKey)
                        .map { KeyAndSignature(key: inbox.publicKey, signature: $0.publicKey) }
                        .eraseToAnyPublisher()
                }

            let pullChat = challenges
                .withUnretained(self)
                .flatMap { owner, keyAndSignature -> AnyPublisher<KeyAndMessages, Error> in
                    owner.chatService.pullInboxMessages(publicKey: keyAndSignature.key, signature: keyAndSignature.signature)
                        .withUnretained(self)
                        .handleEvents(receiveOutput: { owner, messages in
                            let updatedMessages = owner.messages + messages
                            owner.messages.append(contentsOf: updatedMessages)
                        })
                        .map { _, messages in KeyAndMessages(key: keyAndSignature.key, messages: messages) }
                        .eraseToAnyPublisher()
                }

            let deleteChat = pullChat
                .withUnretained(self)
                .flatMap { owner, keyAndMessages -> AnyPublisher<[ChatMessage], Error> in
                    owner.chatService.deleteInboxMessages(publicKey: keyAndMessages.key)
                        .map { _ in keyAndMessages.messages }
                        .eraseToAnyPublisher()
                }

            return deleteChat
                .collect()
                .map { Array($0.joined()) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: ChatError.storageEmpty)
                .eraseToAnyPublisher()
        }
    }
}
