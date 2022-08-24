//
//  ChatService.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Combine

protocol ChatServiceType {

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error>

    // MARK: - Create inbox and request messaging permission

    func createInbox(eccKeys: ECCKeys, pushToken: String?) -> AnyPublisher<Void, Error>
    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
    func communicationConfirmation(confirmation: Bool,
                                   message: MessagePayload?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String) -> AnyPublisher<Void, Error>

    // MARK: - Sync up inboxes

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

    @Inject private var cryptoService: CryptoServiceType

    // MARK: - Create inbox and request messaging permission

    func createInbox(eccKeys: ECCKeys, pushToken: String?) -> AnyPublisher<Void, Error> {
        getSignedChallenge(eccKeys: eccKeys)
            .withUnretained(self)
            .flatMapLatest { owner, signedChallenge in
                owner.request(
                    endpoint: ChatRouter.createInbox(
                        publicKey: eccKeys.publicKey,
                        pushToken: pushToken,
                        signedChallenge: signedChallenge
                    )
                )
            }
            .eraseToAnyPublisher()
    }

    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error> {
            cryptoService
                .encryptECIES(publicKey: inboxPublicKey, secret: message)
                .flatMapLatest(with: self) { owner, encryptedMessage in
                    owner.request(endpoint: ChatRouter.request(inboxPublicKey: inboxPublicKey, message: encryptedMessage))
                }
            .eraseToAnyPublisher()
    }

    func communicationConfirmation(confirmation: Bool,
                                   message: MessagePayload?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String) -> AnyPublisher<Void, Error> {
        if let parsedMessage = message, let messageAsString = parsedMessage.asString {
            return Publishers.CombineLatest(
                getSignedChallenge(eccKeys: inboxKeys),
                cryptoService
                    .encryptECIES(publicKey: requesterPublicKey, secret: messageAsString)
            )
            .withUnretained(self)
            .flatMapLatest { owner, data -> AnyPublisher<Void, Error> in
                let (signedChallenge, encryptedMessage) = data
                return owner.request(
                    endpoint: ChatRouter.requestConfirmation(
                        confirmed: confirmation,
                        message: encryptedMessage,
                        inboxPublicKey: inboxKeys.publicKey,
                        requesterPublicKey: requesterPublicKey,
                        signedChallenge: signedChallenge
                    )
                )
            }
            .eraseToAnyPublisher()
        } else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    // MARK: - Sync up inboxes

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
        cryptoService
            .encryptECIES(publicKey: receiverPublicKey, secret: message)
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

    // MARK: - Private methods

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error> {
        request(type: ChatChallenge.self, endpoint: ChatRouter.requestChallenge(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    private func getSignedChallenge(eccKeys: ECCKeys) -> AnyPublisher<SignedChallenge, Error> {
        requestChallenge(publicKey: eccKeys.publicKey)
            .withUnretained(self)
            .flatMapLatest { owner, challenge in
                owner.cryptoService
                    .signECDSA(
                        keys: eccKeys,
                        message: challenge.challenge
                    )
                    .map { signature in
                        SignedChallenge(challenge: challenge.challenge, signature: signature)
                    }
            }
            .eraseToAnyPublisher()
    }
}
