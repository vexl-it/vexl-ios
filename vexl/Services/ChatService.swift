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

    func createInbox(offerKey: ECCKeys, pushToken: String) -> AnyPublisher<Void, Error>
    func requestCommunication(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
    func communicationConfirmation(confirmation: Bool,
                                   message: ParsedChatMessage?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String,
                                   signature: String) -> AnyPublisher<Void, Error>

    // MARK: - Sync up inboxes

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error>
    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<EncryptedChatMessageList, Error>
    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error>
    func saveParsedMessages(_ messages: [ParsedChatMessage], inboxKeys: ECCKeys) -> AnyPublisher<Void, Error>

    // MARK: - Chat functionalities

    func sendMessage(inboxKeys: ECCKeys,
                     receiverPublicKey: String,
                     message: String,
                     messageType: MessageType) -> AnyPublisher<Void, Error>
    func setInboxBlock(inboxPublicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool) -> AnyPublisher<Void, Error>

    // MARK: - Storage

    func getStoredInboxMessages() -> AnyPublisher<[ChatInboxMessage], Error>
    func getStoredRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func getStoredChatMessages(inboxPublicKey: String, contactPublicKey: String) -> AnyPublisher<[ParsedChatMessage], Error>
    func deleteMessages(inboxPublicKey: String, contactPublicKey: String) -> AnyPublisher<Void, Error>
    func getContactIdentity(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<ParsedChatMessage.ChatUser, Error>
    func getStoredContactIdentities() -> AnyPublisher<[StoredChatUser], Error>
    func updateIdentityReveal(inboxKeys: ECCKeys, contactPublicKey: String, isAccepted: Bool) -> AnyPublisher<Void, Error>
    func createRevealedUser(forInboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error>
}

final class ChatService: BaseService, ChatServiceType {

    @Inject private var cryptoService: CryptoServiceType
    @Inject private var localStorageService: LocalStorageServiceType

    // MARK: - Create inbox and request messaging permission

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

    func communicationConfirmation(confirmation: Bool,
                                   message: ParsedChatMessage?,
                                   inboxKeys: ECCKeys,
                                   requesterPublicKey: String,
                                   signature: String) -> AnyPublisher<Void, Error> {
        if let parsedMessage = message, let messageAsString = parsedMessage.asString {
            return cryptoService
                .encryptECIES(publicKey: requesterPublicKey, secret: messageAsString)
                .flatMapLatest(with: self) { owner, encryptedMessage in
                    owner.request(endpoint: ChatRouter.requestConfirmation(confirmed: confirmation,
                                                                           message: encryptedMessage,
                                                                           inboxPublicKey: inboxKeys.publicKey,
                                                                           requesterPublicKey: requesterPublicKey,
                                                                           signature: signature))
                }
                .flatMapLatest(with: self) { owner, _ in
                    owner.saveCommunicationResponse(parsedMessage, inboxKeys: inboxKeys, isConfirmed: confirmation)
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

    func saveParsedMessages(_ messages: [ParsedChatMessage], inboxKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        let filteredMessages = messages.filter { $0.shouldBeStored }
        return localStorageService.saveMessages(filteredMessages)
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<Void, Error> in
                owner.prepareMessages(messages, inboxKeys: inboxKeys)
            }
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

    // MARK: - Storage

    func getStoredInboxMessages() -> AnyPublisher<[ChatInboxMessage], Error> {
        localStorageService.getInboxMessages()
    }

    func getStoredRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error> {
        localStorageService.getRequestMessages()
    }

    func getStoredChatMessages(inboxPublicKey: String, contactPublicKey: String) -> AnyPublisher<[ParsedChatMessage], Error> {
        localStorageService.getChatMessages(inboxPublicKey: inboxPublicKey, contactPublicKey: contactPublicKey)
    }

    func deleteMessages(inboxPublicKey: String, contactPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.deleteChatMessages(forInbox: inboxPublicKey, contactPublicKey: contactPublicKey)
    }

    func getContactIdentity(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<ParsedChatMessage.ChatUser, Error> {
        localStorageService.getRevealedUser(inboxPublicKey: inboxKeys.publicKey, contactPublicKey: contactPublicKey)
            .compactMap { user -> ParsedChatMessage.ChatUser? in
                guard let user = user else {
                    return nil
                }
                return user
            }
            .eraseToAnyPublisher()
    }

    func updateIdentityReveal(inboxKeys: ECCKeys, contactPublicKey: String, isAccepted: Bool) -> AnyPublisher<Void, Error> {
        localStorageService.updateIdentityReveal(inboxPublicKey: inboxKeys.publicKey, contactPublicKey: contactPublicKey, isAccepted: isAccepted)
    }

    func createRevealedUser(forInboxKeys inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.createRevealedUser(fromInboxPublicKey: inboxKeys.publicKey, contactPublicKey: contactPublicKey)
    }

    func getStoredContactIdentities() -> AnyPublisher<[StoredChatUser], Error> {
        localStorageService.getStoredChatUsers()
    }
}

// MARK: - Helpers

extension ChatService {

    // TODO: - Consider moving this to the inbox manager that will process received messages

    private func prepareMessages(_ messages: [ParsedChatMessage], inboxKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        messages.publisher
            .withUnretained(self)
            .flatMap { owner, message -> AnyPublisher<Void, Error> in
                switch message.messageType {
                case .messagingRequest:
                    return owner.saveCommunicationRequest(message, inboxPublicKey: inboxKeys.publicKey)
                case .messagingApproval:
                    return owner.saveAcceptedRequest(message, inboxKeys: inboxKeys)
                case .message:
                    return owner.saveLastMessageForInbox(messages, inboxKeys: inboxKeys)
                case .deleteChat:
                    return owner.deleteMessageRequest(messages, inboxKey: inboxKeys)
                case .revealApproval:
                    return owner.updatedRevealIdentityMessage(message, inboxKeys: inboxKeys, isAccepted: true)
                case .revealRejected:
                    return owner.updatedRevealIdentityMessage(message, inboxKeys: inboxKeys, isAccepted: false)
                case .invalid, .revealRequest, .messagingRejection:
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .collect()
            .asVoid()
            .eraseToAnyPublisher()
    }

    private func updatedRevealIdentityMessage(_ message: ParsedChatMessage, inboxKeys: ECCKeys, isAccepted: Bool) -> AnyPublisher<Void, Error> {
        localStorageService.updateIdentityReveal(inboxPublicKey: inboxKeys.publicKey,
                                                 contactPublicKey: message.contactInboxKey,
                                                 isAccepted: isAccepted)
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Void, Error> in
                if isAccepted {
                    return owner.saveRevealedUserMessage(message, inboxKeys: inboxKeys)
                        .eraseToAnyPublisher()
                } else {
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func saveRevealedUserMessage(_ message: ParsedChatMessage, inboxKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        guard let chatUser = message.user else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return localStorageService.saveRevealedUser(chatUser, inboxPublicKey: inboxKeys.publicKey, contactPublicKey: message.contactInboxKey)
    }

    private func saveLastMessageForInbox(_ messages: [ParsedChatMessage], inboxKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        guard let displayMessage = messages.last else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return localStorageService.saveInboxMessage(displayMessage, inboxKeys: inboxKeys)
    }

    private func saveCommunicationRequest(_ message: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        localStorageService.saveRequestMessage(message, inboxPublicKey: inboxPublicKey)
    }

    private func saveCommunicationResponse(_ message: ParsedChatMessage, inboxKeys: ECCKeys, isConfirmed: Bool) -> AnyPublisher<Void, Error> {
        localStorageService.deleteRequestMessage(withOfferId: inboxKeys.publicKey)
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
                    return owner.localStorageService.saveInboxMessage(message, inboxKeys: inboxKeys)
                } else {
                    return Just(()).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func saveAcceptedRequest(_ message: ParsedChatMessage, inboxKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        localStorageService.saveInboxMessage(message, inboxKeys: inboxKeys)
    }

    private func deleteMessageRequest(_ messages: [ParsedChatMessage], inboxKey: ECCKeys) -> AnyPublisher<Void, Error> {
        guard let message = messages.first else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return deleteMessages(inboxPublicKey: inboxKey.publicKey, contactPublicKey: message.contactInboxKey)
    }
}
