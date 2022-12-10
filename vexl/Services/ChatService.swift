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
    func deleteInboxes(eccKeys: [ECCKeys]) -> AnyPublisher<Void, Error>
    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<EncryptedChatMessage, Error>
    func communicationConfirmation(confirmation: Bool,
                                   message: MessagePayload?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String) -> AnyPublisher<EncryptedChatMessage, Error>

    // MARK: - Sync up inboxes

    func pullInboxMessages(publicKey: String, eccKeys: ECCKeys) -> AnyPublisher<EncryptedChatMessageList, Error>
    func deleteInboxMessages(publicKey: String, eccKeys: ECCKeys) -> AnyPublisher<Void, Error>

    // MARK: - Chat functionalities

    func sendMessage(inboxKeys: ECCKeys,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType,
                     eccKeys: ECCKeys) -> AnyPublisher<EncryptedChatMessage, Error>

    func sendMessages(envelopes: [(ECCKeys, BatchMessageEnvelope)]) -> AnyPublisher<[EncryptedChatMessage], Error>
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
            .flatMap { owner, signedChallenge in
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

    func deleteInboxes(eccKeys: [ECCKeys]) -> AnyPublisher<Void, Error> {
        getSignedChallenges(keys: eccKeys)
            .map { challenges in
                challenges.map { ($0.publicKey, $1) }
            }
            .withUnretained(self)
            .flatMap { owner, pubKeysAndChallenges in
                owner.request(endpoint: ChatRouter.deleteInboxes(pubKeysAndChallenges: pubKeysAndChallenges))
            }
            .eraseToAnyPublisher()
    }

    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<EncryptedChatMessage, Error> {
            cryptoService
                .encryptECIES(publicKey: inboxPublicKey, secret: message)
                .flatMapLatest(with: self) { owner, encryptedMessage in
                    owner.request(
                        type: EncryptedChatMessage.self,
                        endpoint: ChatRouter.request(inboxPublicKey: inboxPublicKey, message: encryptedMessage)
                    )
                }
            .eraseToAnyPublisher()
    }

    func communicationConfirmation(confirmation: Bool,
                                   message: MessagePayload?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String) -> AnyPublisher<EncryptedChatMessage, Error> {
        guard let parsedMessage = message, let messageAsString = parsedMessage.asString else {
            return Fail(error: PersistenceError.insufficientData).eraseToAnyPublisher()
        }
        return Publishers.CombineLatest(
            getSignedChallenge(eccKeys: inboxKeys),
            cryptoService
                .encryptECIES(publicKey: requesterPublicKey, secret: messageAsString)
        )
        .withUnretained(self)
        .flatMapLatest { owner, data -> AnyPublisher<EncryptedChatMessage, Error> in
            let (signedChallenge, encryptedMessage) = data
            return owner.request(
                type: EncryptedChatMessage.self,
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
                     eccKeys: ECCKeys) -> AnyPublisher<EncryptedChatMessage, Error> {
        Publishers.Zip(
            getSignedChallenge(eccKeys: eccKeys),
            cryptoService
                .encryptECIES(publicKey: receiverPublicKey, secret: message)
        )
        .withUnretained(self)
        .flatMapLatest { owner, data -> AnyPublisher<EncryptedChatMessage, Error> in
            let (signedChallenge, encryptedMessage) = data
            return owner.request(
                type: EncryptedChatMessage.self,
                endpoint: ChatRouter.sendMessage(
                    envelope: MessageEnvelope(
                        senderPublicKey: inboxKeys.publicKey,
                        receiverPublicKey: receiverPublicKey,
                        message: encryptedMessage,
                        messageType: messageType
                    ),
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

    func sendMessages(envelopes: [(ECCKeys, BatchMessageEnvelope)]) -> AnyPublisher<[EncryptedChatMessage], Error> {
        Publishers.Zip(
            getSignedChallenges(keys: envelopes.map(\.0)),
            encryptMultiple(envelopes: envelopes)
        )
        .map { signedChallenges, encryptedEnvelopes -> [(BatchMessageEnvelope, SignedChallenge)] in
            let pkChallengeMap = signedChallenges.reduce(into: [String: SignedChallenge]()) { map, challenge in
                map[challenge.0.publicKey] = challenge.1
            }
            return encryptedEnvelopes.compactMap { envelope -> (BatchMessageEnvelope, SignedChallenge)? in
                guard let challenge = pkChallengeMap[envelope.0.publicKey] else {
                    return nil
                }
                return (envelope.1, challenge)
            }
        }
        .withUnretained(self)
        .flatMap { owner, signedEnvelopes in
            owner.request(
                type: [EncryptedChatMessage].self,
                endpoint: ChatRouter.sendMessages(signedEnvelopes: signedEnvelopes)
            )
            .eraseToAnyPublisher()
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
            .flatMap { [cryptoService] challenge in
                cryptoService
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

    private func requestChallenges(eccKeys: [ECCKeys]) -> AnyPublisher<[(ECCKeys, String)], Error> {
        let pkMap = eccKeys.reduce(into: [String: ECCKeys]()) { partialResult, eccKeys in
            partialResult[eccKeys.publicKey] = eccKeys
        }
        let pubKeys = eccKeys.map(\.publicKey)
        return request(type: BatchChallengeEnvelope.self, endpoint: ChatRouter.requestChallenges(publicKeys: pubKeys))
            .map { batchEnvelope in
                batchEnvelope.challenges.compactMap { challenge -> (ECCKeys, String)? in
                    guard let eccKeys = pkMap[challenge.publicKey] else {
                        return nil
                    }
                    return (eccKeys, challenge.challenge)
                }
            }
            .eraseToAnyPublisher()
    }

    private func getSignedChallenges(keys: [ECCKeys]) -> AnyPublisher<[(ECCKeys, SignedChallenge)], Error> {
        requestChallenges(eccKeys: keys)
            .flatMap { [cryptoService] challenges in
                challenges
                    .publisher
                    .flatMap(maxPublishers: .max(1)) { eccKeys, challenge in
                        cryptoService
                            .signECDSA(
                                keys: eccKeys,
                                message: challenge
                            )
                            .map { signature in
                                (eccKeys, SignedChallenge(challenge: challenge, signature: signature))
                            }
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }

    private func encryptMultiple(envelopes: [(ECCKeys, BatchMessageEnvelope)]) -> AnyPublisher<[(ECCKeys, BatchMessageEnvelope)], Error> {
        envelopes
            .publisher
            .flatMap { [cryptoService] eccKeys, envelope in
                envelope.messages
                    .publisher
                    .flatMap { message in
                        cryptoService
                            .encryptECIES(publicKey: message.receiverPublicKey, secret: message.message)
                            .map { encryptedMessage in
                                ChatMessageEnvelope(
                                    receiverPublicKey: message.receiverPublicKey,
                                    message: encryptedMessage,
                                    messageType: message.messageType
                                )
                            }
                    }
                    .collect()
                    .map { (messages: [ChatMessageEnvelope]) in
                        (eccKeys, BatchMessageEnvelope(senderPublicKey: envelope.senderPublicKey, messages: messages))
                    }
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
