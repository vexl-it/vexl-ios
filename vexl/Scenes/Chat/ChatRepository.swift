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

    func getContactIdentity(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<ParsedChatMessage.ChatUser, Error>
    func deleteChat(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error>

    func requestIdentityReveal(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<Void, Error>
    func identityRevealResponse(inboxKeys: ECCKeys, contactPublicKey: String, isAccepted: Bool) -> AnyPublisher<Void, Error>

    func sendMessage(inboxKeys: ECCKeys,
                     receiverPublicKey: String,
                     type: MessageType,
                     parsedMessage: ParsedChatMessage?,
                     updateInbox: Bool) -> AnyPublisher<Void, Never>
}

final class ChatRepository: ChatRepositoryType {

    @Inject private var chatService: ChatServiceType
    @Inject private var cryptoService: CryptoServiceType
    @Inject private var inboxManager: InboxManagerType
    @Inject private var authenticationManager: AuthenticationManagerType
    @Inject private var localStorageService: LocalStorageServiceType

    var dismissAction: ActionSubject<Void> = .init()

    func getContactIdentity(inboxKeys: ECCKeys, contactPublicKey: String) -> AnyPublisher<ParsedChatMessage.ChatUser, Error> {
        chatService.getContactIdentity(inboxKeys: inboxKeys, contactPublicKey: contactPublicKey)
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
                                                                      contactInboxKey: contactPublicKey,
                                                                      username: authenticationManager.currentUser?.username,
                                                                      avatar: authenticationManager.currentUser?.avatar)

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

        return chatService
            .updateIdentityReveal(inboxKeys: inboxKeys, contactPublicKey: contactPublicKey, isAccepted: isAccepted)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Void, Never> in
                if isAccepted {
                    return owner.chatService
                        .createRevealedUser(forInboxKeys: inboxKeys, contactPublicKey: contactPublicKey)
                        .materialize()
                        .compactMap(\.value)
                        .eraseToAnyPublisher()
                } else {
                    return Just(())
                        .eraseToAnyPublisher()
                }
            }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.sendMessage(inboxKeys: inboxKeys,
                                  receiverPublicKey: contactPublicKey,
                                  type: isAccepted ? .revealApproval : .revealRejected,
                                  parsedMessage: identityResponse,
                                  updateInbox: true)
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func sendMessage(inboxKeys: ECCKeys,
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
