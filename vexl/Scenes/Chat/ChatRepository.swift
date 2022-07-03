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
}

final class ChatRepository {

    @Inject var chatService: ChatServiceType
    @Inject var cryptoService: CryptoServiceType
    @Inject var inboxManager: InboxManagerType

    func deleteChat(senderKey: ECCKeys, receiverPublicKey: String) -> AnyPublisher<Void, Error> {
        let deleteMessage = ParsedChatMessage.createDelete(inboxPublicKey: receiverPublicKey,
                                                           senderPublicKey: senderKey.publicKey)

        return Just(deleteMessage)
            .setFailureType(to: Error.self)
            .compactMap { $0?.asString }
            .withUnretained(self)
            .flatMap { owner, message in
                owner.cryptoService
                    .encryptECIES(publicKey: receiverPublicKey, secret: message)
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.sendMessage(inboxKeys: senderKey,
                                  receiverPublicKey: receiverPublicKey,
                                  type: .deleteChat,
                                  parsedMessage: deleteMessage)
            }
            .eraseToAnyPublisher()
    }

    private func sendMessage(inboxKeys: ECCKeys,
                             receiverPublicKey: String,
                             type: MessageType,
                             parsedMessage: ParsedChatMessage?) -> AnyPublisher<Void, Never> {
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
                .flatMapLatest(with: self) { owner, _ in
                    owner.inboxManager.updateInboxMessages()
                        .materialize()
                        .compactMap(\.value)
                }
                .asVoid()
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .eraseToAnyPublisher()
        }
    }
}
