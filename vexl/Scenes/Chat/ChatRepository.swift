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

    func deleteChat(senderKey: ECCKeys, receiverPublicKey: String) -> AnyPublisher<Void, Error>
    func requestIdentityReveal(senderKey: ECCKeys, receiverPublicKey: String) -> AnyPublisher<Void, Error>
}

final class ChatRepository: ChatRepositoryType {

    @Inject private var chatService: ChatServiceType
    @Inject private var cryptoService: CryptoServiceType
    @Inject private var inboxManager: InboxManagerType

    var dismissAction: ActionSubject<Void> = .init()

    func deleteChat(senderKey: ECCKeys, receiverPublicKey: String) -> AnyPublisher<Void, Error> {
        let deleteMessage = ParsedChatMessage.createDelete(inboxPublicKey: receiverPublicKey,
                                                           senderPublicKey: senderKey.publicKey)

        let sendMessage = encryptMessage(deleteMessage,
                                         publicKey: receiverPublicKey)
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.sendMessage(inboxKeys: senderKey,
                                  receiverPublicKey: receiverPublicKey,
                                  type: .deleteChat,
                                  parsedMessage: deleteMessage,
                                  updateInbox: false)
            }

        return sendMessage
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.chatService
                    .deleteMessages(inboxPublicKey: senderKey.publicKey,
                                    senderPublicKey: receiverPublicKey)
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

    func requestIdentityReveal(senderKey: ECCKeys, receiverPublicKey: String) -> AnyPublisher<Void, Error> {
        let requestIdentity = ParsedChatMessage.createIdentityRequest(inboxPublicKey: senderKey.publicKey,
                                                                      senderPublicKey: receiverPublicKey)

        return encryptMessage(requestIdentity, publicKey: receiverPublicKey)
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.sendMessage(inboxKeys: senderKey,
                                  receiverPublicKey: receiverPublicKey,
                                  type: .revealRequest,
                                  parsedMessage: requestIdentity,
                                  updateInbox: true)
            }
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
