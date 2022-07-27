//
//  ChatService.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Combine

protocol ChatServiceType {

    // MARK: - Create inbox and request messaging permission

    func createInbox(publicKey: String, pushToken: String) -> AnyPublisher<Void, Error>
    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
    func communicationConfirmation(confirmation: Bool,
                                   message: MessagePayload?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String,
                                   signature: String) -> AnyPublisher<Void, Error>

    // MARK: - Sync up inboxes

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error>
    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<EncryptedChatMessageList, Error>
    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error>

    // MARK: - Chat functionalities

    func sendMessage(inboxKeys: ECCKeys,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType) -> AnyPublisher<Void, Error>
    func setInboxBlock(inboxPublicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool) -> AnyPublisher<Void, Error>
}

final class ChatService: BaseService, ChatServiceType {

    // TODO: [vexl chat encryption] Uncomment this when enabling encryption on chat service
//    @Inject private var cryptoService: CryptoServiceType

    // MARK: - Create inbox and request messaging permission

    func createInbox(publicKey: String, pushToken: String) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.createInbox(publicKey: publicKey, pushToken: pushToken))
            .eraseToAnyPublisher()
    }

    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error> {
        // TODO: [vexl chat encryption] Uncomment this when enabling encryption on chat service
//            owner.cryptoService
//                .encryptECIES(publicKey: inboxPublicKey, secret: message)
        Just(message)
            .setFailureType(to: Error.self)
            .flatMapLatest(with: self) { owner, encryptedMessage in
                owner.request(endpoint: ChatRouter.request(inboxPublicKey: inboxPublicKey, message: encryptedMessage))
            }
            .eraseToAnyPublisher()
    }

    func communicationConfirmation(confirmation: Bool,
                                   message: MessagePayload?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String,
                                   signature: String) -> AnyPublisher<Void, Error> {
        if let parsedMessage = message, let messageAsString = parsedMessage.asString {
            // TODO: [vexl chat encryption] Uncomment this when enabling encryption on chat service
//            return cryptoService
//                .encryptECIES(publicKey: requesterPublicKey, secret: messageAsString)
            return Just(messageAsString)
                .setFailureType(to: Error.self)
                .flatMapLatest(with: self) { owner, encryptedMessage in
                    owner.request(endpoint: ChatRouter.requestConfirmation(confirmed: confirmation,
                                                                           message: encryptedMessage,
                                                                           inboxPublicKey: inboxKeys.publicKey,
                                                                           requesterPublicKey: requesterPublicKey,
                                                                           signature: signature))
                }
                .eraseToAnyPublisher()
        } else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    // MARK: - Sync up inboxes

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error> {
        // TODO: - add expiration handling so that it is not requested everytime, find a way to cache the challenge for 30m
        request(type: ChatChallenge.self, endpoint: ChatRouter.requestChallenge(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<EncryptedChatMessageList, Error> {
        request(type: EncryptedChatMessageList.self, endpoint: ChatRouter.pullChat(publicKey: publicKey, signature: signature))
            .eraseToAnyPublisher()
    }

    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.deleteChatMessages(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    // MARK: - Chat functionalities

    func sendMessage(inboxKeys: ECCKeys,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType) -> AnyPublisher<Void, Error> {
        // TODO: [vexl chat encryption] Uncomment this when enabling encryption on chat service
//        cryptoService
//            .encryptECIES(publicKey: receiverPublicKey, secret: message)
        Just(message)
            .setFailureType(to: Error.self)
            .flatMapLatest(with: self) { owner, encryptedMessage in
                owner.request(endpoint: ChatRouter.sendMessage(senderPublicKey: inboxKeys.publicKey,
                                                               receiverPublicKey: receiverPublicKey,
                                                               message: encryptedMessage,
                                                               messageType: messageType))
            }
            .eraseToAnyPublisher()
    }

    func setInboxBlock(inboxPublicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.blockInbox(publicKey: inboxPublicKey,
                                                publicKeyToBlock: publicKeyToBlock,
                                                signature: signature,
                                                isBlocked: isBlocked))
    }
}
