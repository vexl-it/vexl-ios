//
//  ChatRepository.swift
//  vexl
//
//  Created by Diego Espinoza on 3/07/22.
//

import Foundation
import Combine
import Cleevio

protocol ChatRepositoryType {
    var dismissAction: ActionSubject<Void> { get set }

    func getContactIdentity(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<(username: String, avatar: String?), Error>
    func deleteChat(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error>
    func requestIdentityReveal(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error>
    func identityRevealResponse(inboxKeys: ECCKeys, contactPublicKey: String, isAccepted: Bool) -> AnyPublisher<Void, Error>
}

final class ChatRepository: ChatRepositoryType {

    @Inject private var chatService: ChatServiceType
    @Inject private var cryptoService: CryptoServiceType
    @Inject private var inboxManager: InboxManagerType
    @Inject private var authenticationManager: AuthenticationManagerType
    @Inject private var localStorageService: LocalStorageServiceType

    var dismissAction: ActionSubject<Void> = .init()

    func getContactIdentity(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<(username: String, avatar: String?), Error> {
        localStorageService.getRevealedUser(inboxPublicKey: inboxKeys.publicKey, contactPublicKey: contactPublicKey)
            .compactMap { user -> (username: String, avatar: String?)? in
                guard let user = user else {
                    return nil
                }
                return (username: user.name, avatar: user.image)
            }
            .eraseToAnyPublisher()
    }

    func deleteChat(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error> {
        let deleteMessage = ParsedChatMessage.createDelete(inboxPublicKey: inboxKeys.publicKey,
                                                           contactInboxKey: contactPublicKey)

        let sendMessage = sendMessage(inboxKeys: inboxKeys,
                                      receiverPublicKey: contactPublicKey,
                                      type: .deleteChat,
                                      parsedMessage: deleteMessage,
                                      updateInbox: false)

        return sendMessage
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.chatService
                    .deleteMessages(inboxPublicKey: inboxKeys.publicKey, contactPublicKey: contactPublicKey)
            }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.inboxManager.updateInboxMessages()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.dismissAction.send(())
            })
            .asVoid()
            .eraseToAnyPublisher()
    }

    func requestIdentityReveal(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error> {
        let requestIdentity = ParsedChatMessage.createIdentityRequest(inboxPublicKey: inboxKeys.publicKey,
                                                                      contactInboxKey: contactPublicKey)

        return sendMessage(inboxKeys: inboxKeys,
                           receiverPublicKey: contactPublicKey,
                           type: .revealRequest,
                           parsedMessage: requestIdentity,
                           updateInbox: true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func identityRevealResponse(inboxKeys: ECCKeys, contactPublicKey: String, isAccepted: Bool) -> AnyPublisher<Void, Error> {
        let identityResponse = ParsedChatMessage.createIdentityResponse(inboxPublicKey: inboxKeys.publicKey,
                                                                        contactInboxKey: contactPublicKey,
                                                                        isAccepted: isAccepted,
                                                                        username: authenticationManager.currentUser?.username,
                                                                        avatar: authenticationManager.currentUser?.avatar)

        return sendMessage(inboxKeys: inboxKeys,
                           receiverPublicKey: contactPublicKey,
                           type: isAccepted ? .revealApproval : .revealApproval,
                           parsedMessage: identityResponse,
                           updateInbox: true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // MARK: - Helper methods

    private func encryptMessage(_ message: ParsedChatMessage?, publicKey: String) -> AnyPublisher<String, Error> {
        Just(message)
            .setFailureType(to: Error.self)
            .compactMap { $0?.asString }
            .withUnretained(self)
            .flatMap { owner, message in
                owner.cryptoService
                    .encryptECIES(publicKey: publicKey, secret: message)
            }
            .eraseToAnyPublisher()
    }

    private func sendMessage(inboxKeys: ECCKeys,
                             receiverPublicKey: String,
                             type: MessageType,
                             parsedMessage: ParsedChatMessage?,
                             updateInbox: Bool) -> AnyPublisher<Void, Never> {
        if let parsedMessage = parsedMessage, let message = parsedMessage.asString {
            return chatService.sendMessage(inboxKeys: inboxKeys,
                                           receiverPublicKey: receiverPublicKey,
                                           message: message,
                                           messageType: type)
                .materialize()
                .compactMap(\.value)
                .flatMapLatest(with: self) { owner, _ in
                    owner.chatService.saveParsedMessages([parsedMessage], inboxKeys: inboxKeys)
                        .materialize()
                        .compactMap(\.value)
                }
                .flatMapLatest(with: self) { owner, _ -> AnyPublisher<Void, Never> in
                    if updateInbox {
                        return owner.inboxManager.updateInboxMessages()
                            .materialize()
                            .compactMap(\.value)
                            .eraseToAnyPublisher()
                    } else {
                        return Just(())
                            .eraseToAnyPublisher()
                    }
                }
                .asVoid()
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .eraseToAnyPublisher()
        }
    }
}
