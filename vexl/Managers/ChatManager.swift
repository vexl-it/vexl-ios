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
    func identityResponse(allow: Bool, chat: ManagedChat) -> AnyPublisher<Void, Error>
    func communicationResponse(chat: ManagedChat, confirmation: Bool) -> AnyPublisher<Void, Error>
    func setBlockMessaging(isBlocked: Bool, chat: ManagedChat) -> AnyPublisher<Void, Error>
    func setDisplayRevealBanner(shouldDisplay: Bool, chat: ManagedChat) -> AnyPublisher<Void, Error>
}

final class ChatManager: ChatManagerType {
    @Inject var inboxRepository: InboxRepositoryType
    @Inject var chatRepository: ChatRepositoryType
    @Inject var chatService: ChatServiceType
    @Inject var userRepository: UserRepositoryType
    @Inject var cryptoService: CryptoServiceType

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
        guard let inbox = chat.inbox,
              let inboxKeys = inbox.keyPair?.keys,
              let receiverPublicKey = chat.receiverKeyPair?.publicKey,
              let message = payload.asString else {
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
            inboxRepository.createOrUpdateChats(receivedPayloads: [payload], inbox: inbox)
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
            .sendMessage(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey, message: message, messageType: payload.messageType)
            .flatMap { [inboxRepository] in
                inboxRepository.deleteChats(recevedPayloads: [payload], inbox: inbox)
            }
            .asVoid()
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
                avatar: userRepository.user?.profile?.avatarURL
              ),
              let message = payload.asString else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return chatService
            .sendMessage(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey, message: message, messageType: payload.messageType)
            .flatMap { [inboxRepository] in
                inboxRepository.createOrUpdateChats(receivedPayloads: [payload], inbox: inbox)
            }
            .eraseToAnyPublisher()
    }

    func communicationResponse(chat: ManagedChat, confirmation: Bool) -> AnyPublisher<Void, Error> {
        guard let inbox = chat.inbox,
              let inboxKeys = inbox.keyPair?.keys,
              let receiverPublicKey = chat.receiverKeyPair?.publicKey,
              let payload = MessagePayload.communicationConfirmation(
                isConfirmed: confirmation,
                inboxPublicKey: inboxKeys.publicKey,
                contactInboxKey: receiverPublicKey
              ) else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }

        return chatService.requestChallenge(publicKey: inboxKeys.publicKey)
            .flatMap { [cryptoService] challenge in
                cryptoService.signECDSA(keys: inboxKeys, message: challenge.challenge)
            }
            .flatMap { [chatService] signature in
                chatService
                    .communicationConfirmation(confirmation: confirmation,
                                               message: payload,
                                               inboxKeys: inboxKeys,
                                               requesterPublicKey: receiverPublicKey,
                                               signature: signature)
            }
            .flatMap { [inboxRepository] in
                confirmation
                    ? inboxRepository.createOrUpdateChats(receivedPayloads: [payload], inbox: inbox)
                    : inboxRepository.deleteChats(recevedPayloads: [payload], inbox: inbox)
                        .asVoid()
                        .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func identityResponse(allow: Bool, chat: ManagedChat) -> AnyPublisher<Void, Error> {
        guard let inbox = chat.inbox,
              let inboxKeys = inbox.keyPair?.keys,
              let receiverPublicKey = chat.receiverKeyPair?.publicKey,
              let payload = MessagePayload.createIdentityResponse(
                inboxPublicKey: inboxKeys.publicKey,
                contactInboxKey: receiverPublicKey,
                isAccepted: allow,
                username: allow ? userRepository.user?.profile?.name : nil,
                avatar: allow ? userRepository.user?.profile?.avatarURL : nil
              ),
              let message = payload.asString else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return chatService
            .sendMessage(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey, message: message, messageType: payload.messageType)
            .flatMap { [inboxRepository] in
                inboxRepository.createOrUpdateChats(receivedPayloads: [payload], inbox: inbox)
            }
            .eraseToAnyPublisher()
    }

    func setBlockMessaging(isBlocked: Bool, chat: ManagedChat) -> AnyPublisher<Void, Error> {
        guard let inbox = chat.inbox,
              let inboxKeys = inbox.keyPair?.keys,
              let receiverPublicKey = chat.receiverKeyPair?.publicKey else {
                  return Fail(error: PersistenceError.insufficientData)
                      .eraseToAnyPublisher()
              }

        return chatService
            .requestChallenge(publicKey: inboxKeys.publicKey)
            .withUnretained(self)
            .flatMap { owner, challenge in
                owner.cryptoService
                    .signECDSA(keys: inboxKeys, message: challenge.challenge)
            }
            .withUnretained(self)
            .flatMap { owner, signature in
                owner.chatService
                    .setInboxBlock(inboxPublicKey: inboxKeys.publicKey,
                                   publicKeyToBlock: receiverPublicKey,
                                   signature: signature,
                                   isBlocked: isBlocked)
            }
            .withUnretained(self)
            .flatMap { owner in
                owner.chatRepository
                    .setBlockChat(chat: chat, isBlocked: isBlocked)
            }
            .asVoid()
            .eraseToAnyPublisher()
    }

    func setDisplayRevealBanner(shouldDisplay: Bool, chat: ManagedChat) -> AnyPublisher<Void, Error> {
        chatRepository
            .setDisplayRevealBanner(chat: chat, shouldDisplay: shouldDisplay)
            .asVoid()
            .eraseToAnyPublisher()
    }
}
