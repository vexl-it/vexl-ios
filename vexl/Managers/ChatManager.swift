//
//  ChatManager.swift
//  vexl
//
//  Created by Adam Salih on 21.07.2022.
//

import Foundation
import Combine

protocol ChatManagerType {
    func requestCommunication(offer: ManagedOffer, receiverPublicKey: String, messagePayload: MessagePayload) -> AnyPublisher<Void, Error>

    func send(payload: MessagePayload, chat: ManagedChat) ->AnyPublisher<Void, Error>
    func delete(chat: ManagedChat) -> AnyPublisher<Void, Error>
    func requestIdentity(chat: ManagedChat) -> AnyPublisher<Void, Error>
}

final class ChatManager: ChatManagerType {
    @Inject var inboxRepository: InboxRepositoryType
    @Inject var chatRepository: ChatRepositoryType
    @Inject var chatService: ChatServiceType
    @Inject var userRepository: UserRepositoryType

    func requestCommunication(offer: ManagedOffer, receiverPublicKey: String, messagePayload: MessagePayload) -> AnyPublisher<Void, Error> {
        guard let payload = messagePayload.asString else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return chatService
            .requestCommunication(inboxPublicKey: receiverPublicKey, message: payload)
            .flatMap { [chatRepository] _ in
                chatRepository
                    .createChat(requestedOffer: offer, receiverPublicKey: receiverPublicKey, requestMessage: messagePayload.text ?? "")
            }
            .asVoid()
            .eraseToAnyPublisher()
    }

    func send(payload: MessagePayload, chat: ManagedChat) ->AnyPublisher<Void, Error> {
        guard let inboxKeys = chat.inbox?.keyPair?.keys,
              let receiverPublicKey = chat.receiverKeyPair?.publicKey,
              let message = payload.asString,
              let inbox = chat.inbox else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return chatService.sendMessage(
            inboxKeys: inboxKeys,
            receiverPublicKey: receiverPublicKey,
            message: message,
            messageType: payload.messageType
        )
        .flatMap { [inboxRepository] in
            inboxRepository.deleteChats(recevedPayloads: [payload], inbox: inbox)
        }
        .eraseToAnyPublisher()
    }

    func delete(chat: ManagedChat) -> AnyPublisher<Void, Error> {
        guard let inbox = chat.inbox,
              let inboxKeys = inbox.keyPair?.keys,
              let receiverPublicKey = chat.receiverKeyPair?.publicKey,
              let payload = MessagePayload.createDelete(inboxPublicKey: inboxKeys.publicKey, contactInboxKey: receiverPublicKey),
              let message = payload.asString else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return chatService
            .sendMessage(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey, message: message, messageType: .deleteChat)
            .flatMap { [inboxRepository] in
                inboxRepository.deleteChats(recevedPayloads: [payload], inbox: inbox)
            }
            .eraseToAnyPublisher()
    }

    func requestIdentity(chat: ManagedChat) -> AnyPublisher<Void, Error> {
        guard let inbox = chat.inbox,
              let inboxKeys = inbox.keyPair?.keys,
              let receiverPublicKey = chat.receiverKeyPair?.publicKey,
              let payload = MessagePayload.createIdentityRequest(
                inboxPublicKey: inboxKeys.publicKey,
                contactInboxKey: receiverPublicKey,
                username: userRepository.user?.profile?.name,
                avatar: userRepository.user?.profile?.avatar?.base64EncodedString()
              ),
              let message = payload.asString else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return chatService
            .sendMessage(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey, message: message, messageType: .deleteChat)
            .flatMap { [inboxRepository] in
                inboxRepository.createOrUpdateChats(receivedPayloads: [payload], inbox: inbox)
            }
            .eraseToAnyPublisher()
    }
}
