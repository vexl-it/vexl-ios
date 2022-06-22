//
//  ChatService.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Combine

protocol ChatServiceType {
    func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error>
    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
    func communicationConfirmation(confirmation: Bool,
                                   message: ParsedChatMessage?,
                                   inboxPublicKey: String,
                                   requesterPublicKey: String,
                                   signature: String) -> AnyPublisher<Void, Error>

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error>
    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<EncryptedChatMessageList, Error>
    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error>

    func saveFetchedMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error>
    func getInboxMessages() -> AnyPublisher<[ChatInboxMessage], Error>
    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func blockInbox(inboxPublicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool) -> AnyPublisher<Void, Error>
    func sendMessage(inboxPublicKey: String,
                     senderPublicKey: String,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType) -> AnyPublisher<Void, Error>
}

final class ChatService: BaseService, ChatServiceType {

    @Inject private var cryptoService: CryptoServiceType
    @Inject private var localStorageService: LocalStorageServiceType

    func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [localStorageService] promise in
            do {
                try localStorageService.saveInbox(ChatInbox(key: offerKey, type: .created))
                promise(.success(()))
            } catch {
                promise(.failure(LocalStorageError.saveFailed))
            }
        }
        .flatMapLatest(with: self) { owner, _ in
            owner.request(endpoint: ChatRouter.createInbox(offerPublicKey: offerKey.publicKey, pushToken: pushToken))
        }
        .eraseToAnyPublisher()
    }

    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [localStorageService] promise in
            do {
                try localStorageService.saveInbox(ChatInbox(publicKey: inboxPublicKey, type: .requested))
                promise(.success(()))
            } catch {
                promise(.failure(LocalStorageError.saveFailed))
            }
        }
        .flatMapLatest(with: self) { owner, _ in
            owner.cryptoService
                .encryptECIES(publicKey: inboxPublicKey, secret: message)
        }
        .flatMapLatest(with: self) { owner, encryptedMessage in
            owner.request(endpoint: ChatRouter.request(inboxPublicKey: inboxPublicKey, message: encryptedMessage))
        }
        .eraseToAnyPublisher()
    }

    // TODO: - add expiration handling so that it is not requested everytime, find a way to cache the challenge for 30m

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error> {
        request(type: ChatChallenge.self, endpoint: ChatRouter.requestChallenge(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    func communicationConfirmation(confirmation: Bool,
                                   message: ParsedChatMessage?,
                                   inboxPublicKey: String,
                                   requesterPublicKey: String,
                                   signature: String) -> AnyPublisher<Void, Error> {
        if let parsedMessage = message, let messageAsString = parsedMessage.asString {
            return cryptoService
                .encryptECIES(publicKey: requesterPublicKey, secret: messageAsString)
                .flatMapLatest(with: self) { owner, encryptedMessage in
                    owner.request(endpoint: ChatRouter.requestConfirmation(confirmed: confirmation,
                                                                           message: encryptedMessage,
                                                                           inboxPublicKey: inboxPublicKey,
                                                                           requesterPublicKey: requesterPublicKey,
                                                                           signature: signature))
                }
                .flatMapLatest(with: self) { owner, _ in
                    owner.saveCommunicationResponse(parsedMessage, inboxPublicKey: inboxPublicKey, isConfirmed: confirmation)
                }
                .eraseToAnyPublisher()
        } else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<EncryptedChatMessageList, Error> {
        request(type: EncryptedChatMessageList.self, endpoint: ChatRouter.pullChat(publicKey: publicKey, signature: signature))
            .eraseToAnyPublisher()
    }

    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.deleteChatMessages(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    func saveFetchedMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.saveMessages(messages)
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<Void, Error> in
                owner.prepareMessages(messages, inboxPublicKey: inboxPublicKey)
            }
            .eraseToAnyPublisher()
    }

    func getInboxMessages() -> AnyPublisher<[ChatInboxMessage], Error> {
        localStorageService.getInboxMessages()
    }

    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error> {
        localStorageService.getRequestMessages()
    }

    func blockInbox(inboxPublicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.blockInbox(publicKey: inboxPublicKey,
                                                publicKeyToBlock: publicKeyToBlock,
                                                signature: signature,
                                                isBlocked: isBlocked))
    }

    func sendMessage(inboxPublicKey: String,
                     senderPublicKey: String,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType) -> AnyPublisher<Void, Error> {
        cryptoService
            .encryptECIES(publicKey: inboxPublicKey, secret: message)
            .withUnretained(self)
            .flatMap { owner, encryptedMessage in
                owner.request(endpoint: ChatRouter.sendMessage(senderPublicKey: senderPublicKey,
                                                               receiverPublicKey: receiverPublicKey,
                                                               message: encryptedMessage,
                                                               messageType: messageType))
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    private func prepareMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error> {

        let saveEachParticularMessage = messages.publisher
            .withUnretained(self)
            .flatMap { owner, message -> AnyPublisher<Void, Error> in
                switch message.messageType {
                case .messagingRequest:
                    return owner.saveCommunicationRequest(message, inboxPublicKey: inboxPublicKey)
                case .messagingApproval:
                    return owner.saveAcceptedRequest(message, inboxPublicKey: inboxPublicKey)
                case .messagingRejection:
                    return owner.removeRejectedRequest(message, inboxPublicKey: inboxPublicKey)
                case .message:
                    return owner.saveLastMessageForInbox(messages, inboxPublicKey: inboxPublicKey)
                case .deleteChat, .invalid, .revealApproval, .revealRequest:
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .collect()

        return saveEachParticularMessage
            .asVoid()
            .eraseToAnyPublisher()
    }

    private func saveLastMessageForInbox(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        guard let displayMessage = messages.last else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return localStorageService.saveInboxMessage(displayMessage, inboxPublicKey: inboxPublicKey)
    }

    private func saveCommunicationRequest(_ message: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.saveRequestMessage(message, inboxPublicKey: inboxPublicKey)
    }

    private func saveCommunicationResponse(_ message: ParsedChatMessage, inboxPublicKey: String, isConfirmed: Bool) -> AnyPublisher<Void, Error> {
        localStorageService.deleteRequestMessage(withOfferId: inboxPublicKey)
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<Void, Error> in
                if isConfirmed {
                    return owner.localStorageService.saveMessages([message])
                } else {
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<Void, Error> in
                if isConfirmed {
                    return owner.localStorageService.saveInboxMessage(message, inboxPublicKey: inboxPublicKey)
                } else {
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func saveAcceptedRequest(_ message: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.saveInboxMessage(message, inboxPublicKey: inboxPublicKey)
    }

    // TODO: - What to do if the message is APPROVAL_REJECTED? delete from request inbox?

    private func removeRejectedRequest(_ message: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
