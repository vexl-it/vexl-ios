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

    func createInbox(eccKeys: ECCKeys, pushToken: String?) -> AnyPublisher<Void, Error>
    func updateInbox(eccKeys: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error>
    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
    func communicationConfirmation(confirmation: Bool,
                                   message: MessagePayload?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String) -> AnyPublisher<Void, Error>

    // MARK: - Sync up inboxes

    func pullInboxMessages(publicKey: String, eccKeys: ECCKeys) -> AnyPublisher<EncryptedChatMessageList, Error>
    func deleteInboxMessages(publicKey: String, eccKeys: ECCKeys) -> AnyPublisher<Void, Error>

    // MARK: - Chat functionalities

    func sendMessage(inboxKeys: ECCKeys,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType,
                     eccKeys: ECCKeys) -> AnyPublisher<Void, Error>
    func setInboxBlock(inboxPublicKey: String, publicKeyToBlock: String, eccKeys: ECCKeys, isBlocked: Bool) -> AnyPublisher<Void, Error>
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

    func updateInbox(eccKeys: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error> {
        getSignedChallenge(eccKeys: eccKeys)
            .withUnretained(self)
            .flatMapLatest { owner, signedChallenge in
                owner.request(
                    endpoint: ChatRouter.updateInbox(
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

    func pullInboxMessages(publicKey: String, eccKeys: ECCKeys) -> AnyPublisher<EncryptedChatMessageList, Error> {
        getSignedChallenge(eccKeys: eccKeys)
            .withUnretained(self)
            .flatMapLatest { owner, signedChallenge in
                owner.request(
                    type: EncryptedChatMessageList.self,
                    endpoint: ChatRouter.pullChat(
                        publicKey: eccKeys.publicKey,
                        signedChallenge: signedChallenge
                    )
                )
            }
            .eraseToAnyPublisher()
    }

    func deleteInboxMessages(publicKey: String, eccKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        getSignedChallenge(eccKeys: eccKeys)
            .withUnretained(self)
            .flatMapLatest { owner, signedChallenge in
                owner.request(
                    endpoint: ChatRouter.deleteChatMessages(
                        publicKey: publicKey,
                        signedChallenge: signedChallenge
                    )
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Chat functionalities

    func sendMessage(inboxKeys: ECCKeys,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType,
                     eccKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        Publishers.CombineLatest(
            getSignedChallenge(eccKeys: eccKeys),
            cryptoService
                .encryptECIES(publicKey: receiverPublicKey, secret: message)
        )
        .withUnretained(self)
        .flatMapLatest { owner, data -> AnyPublisher<Void, Error> in
            let (signedChallenge, encryptedMessage) = data
            return owner.request(
                endpoint: ChatRouter.sendMessage(
                    senderPublicKey: inboxKeys.publicKey,
                    receiverPublicKey: receiverPublicKey,
                    message: encryptedMessage,
                    messageType: messageType,
                    signedChallenge: signedChallenge
                )
            )
        }
        .eraseToAnyPublisher()
    }

    func setInboxBlock(inboxPublicKey: String, publicKeyToBlock: String, eccKeys: ECCKeys, isBlocked: Bool) -> AnyPublisher<Void, Error> {
        getSignedChallenge(eccKeys: eccKeys)
            .withUnretained(self)
            .flatMapLatest { owner, signedChallenge in
                owner.request(endpoint: ChatRouter.blockInbox(publicKey: inboxPublicKey,
                                                              publicKeyToBlock: publicKeyToBlock,
                                                              signedChallenge: signedChallenge,
                                                              isBlocked: isBlocked))
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private methods

    private func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error> {
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
