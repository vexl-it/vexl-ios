//
//  InboxManager.swift
//  vexl
//
//  Created by Diego Espinoza on 5/06/22.
//

import Foundation
import Combine

private typealias KeyAndSignature = (key: String, signature: String)

protocol InboxManagerType {
    func syncInbox(publicKey: String) -> AnyPublisher<Void, Error>
}

final class InboxManager: InboxManagerType {

    @Inject var chatService: ChatServiceType
    @Inject var localStorageService: LocalStorageServiceType

    var messages: [ChatMessage] = []

    func syncInbox(publicKey: String) -> AnyPublisher<Void, Error> {
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

            let pullAndDelete = challenges
                .withUnretained(self)
                .flatMap { owner, keyAndSignature -> AnyPublisher<String, Error> in
                    owner.chatService.pullInboxMessages(publicKey: keyAndSignature.key, signature: keyAndSignature.signature)
                        .withUnretained(self)
                        .handleEvents(receiveOutput: { owner, messages in
                            owner.messages.append(contentsOf: messages)
                        })
                        .map { _ in keyAndSignature.key }
                        .eraseToAnyPublisher()
                }
                .withUnretained(self)
                .flatMap { owner, key in
                    owner.chatService.deleteInboxMessages(publicKey: key)
                }

            return pullAndDelete
                .collect()
                .asVoid()
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: ChatError.storageEmpty)
                .eraseToAnyPublisher()
        }
    }
}
