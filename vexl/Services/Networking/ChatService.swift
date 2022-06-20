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
    func request(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
    func requestConfirmation(confirmation: Bool,
                             message: String,
                             inboxPublicKey: String,
                             requesterPublicKey: String,
                             signature: String) -> AnyPublisher<Void, Error>

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error>
    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<[EncryptedChatMessage], Error>
    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error>

    func saveFetchedMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error>
    func getInboxMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func blockInbox(inboxPublicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool) -> AnyPublisher<Void, Error>
    func sendMessage(senderPublicKey: String, receiverPublicKey: String, message: String, messageType: MessageType) -> AnyPublisher<Void, Error>
}

final class ChatService: BaseService, ChatServiceType {

    @Inject private var cryptoService: CryptoServiceType
    @Inject private var localStorageService: LocalStorageServiceType

    func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [localStorageService] promise in
            do {
                try localStorageService.saveInbox(OfferInbox(key: offerKey, type: .created))
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

    func request(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [localStorageService] promise in
            do {
                try localStorageService.saveInbox(OfferInbox(publicKey: inboxPublicKey, type: .requested))
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

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error> {
        request(type: ChatChallenge.self, endpoint: ChatRouter.requestChallenge(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    func requestConfirmation(confirmation: Bool,
                             message: String,
                             inboxPublicKey: String,
                             requesterPublicKey: String,
                             signature: String) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.requestConfirmation(confirmed: confirmation,
                                                         message: message,
                                                         inboxPublicKey: inboxPublicKey,
                                                         requesterPublicKey: requesterPublicKey,
                                                         signature: signature))
            .eraseToAnyPublisher()
    }

    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<[EncryptedChatMessage], Error> {
        request(type: [EncryptedChatMessage].self, endpoint: ChatRouter.pullChat(publicKey: publicKey, signature: signature))
            .eraseToAnyPublisher()
    }

    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.deleteChat(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    func saveFetchedMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.saveMessages(messages)
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<Void, Error> in
                owner.saveRequestsMessages(messages, inboxPublicKey: inboxPublicKey)
            }
            .eraseToAnyPublisher()
    }

    func getInboxMessages() -> AnyPublisher<[ParsedChatMessage], Error> {

        // Will fetch data from the display messages / last messages

        Future { promise in
            promise(.success([]))
        }
        .eraseToAnyPublisher()
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

    func sendMessage(senderPublicKey: String, receiverPublicKey: String, message: String, messageType: MessageType) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.sendMessage(senderPublicKey: senderPublicKey,
                                                 receiverPublicKey: receiverPublicKey,
                                                 message: message,
                                                 messageType: messageType))
    }

    // MARK: - Helpers

    private func saveRequestsMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        let request = messages
            .first(where: { $0.messageType == .messagingRequest })

        if let request = request {
            return localStorageService.saveRequestMessage(request, inboxPublicKey: inboxPublicKey)
                .asVoid()
                .eraseToAnyPublisher()
        } else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
