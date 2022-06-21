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
    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<EncryptedChatMessageList, Error>
    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error>

    func saveFetchedMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error>
    func getInboxMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error>
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
        if !message.isEmpty {
            return cryptoService
                .encryptECIES(publicKey: requesterPublicKey, secret: message)
                .flatMapLatest(with: self) { owner, encryptedMessage in
                    owner.request(endpoint: ChatRouter.requestConfirmation(confirmed: confirmation,
                                                                           message: encryptedMessage,
                                                                           inboxPublicKey: inboxPublicKey,
                                                                           requesterPublicKey: requesterPublicKey,
                                                                           signature: signature))
                }
                .flatMapLatest(with: self) { owner, _ in
                    owner.localStorageService.deleteRequestMessage(withOfferId: inboxPublicKey)
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

    func getInboxMessages() -> AnyPublisher<[ParsedChatMessage], Error> {
        localStorageService.getInboxMessages()
    }

    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error> {
        localStorageService.getRequestMessages()
    }

    // MARK: - Helpers

    private func prepareMessages(_ messages: [ParsedChatMessage], inboxPublicKey: String) -> AnyPublisher<Void, Error> {

        let saveEachParticularMessage = messages.publisher
            .withUnretained(self)
            .flatMap { owner, message -> AnyPublisher<Void, Error> in
                switch message.messageType {
                case .messagingRequest:
                    return owner.saveRequestMessage(message, inboxPublicKey: inboxPublicKey)
                case .messagingApproval:
                    return owner.saveAcceptedRequest(message, inboxPublicKey: inboxPublicKey)
                case .messagingRejection:
                    return owner.removeRejectedRequest(message, inboxPublicKey: inboxPublicKey)
                case .deleteChat, .invalid, .message, .revealApproval, .revealRequest:
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .collect()

        let saveDisplayMessage = saveEachParticularMessage
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Void, Error> in
                let displayMessage = messages
                    .last { MessageType.displayableMessages.contains($0.messageType) }

                guard let displayMessage = displayMessage else {
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }

                return owner.localStorageService.saveInboxMessage(displayMessage, inboxPublicKey: inboxPublicKey)
            }

        return saveDisplayMessage
            .eraseToAnyPublisher()
    }

    private func saveRequestMessage(_ message: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.saveRequestMessage(message, inboxPublicKey: inboxPublicKey)
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
