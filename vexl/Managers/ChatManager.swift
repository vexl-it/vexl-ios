//
//  ChatManager.swift
//  vexl
//
//  Created by Adam Salih on 21.07.2022.
//

import Foundation
import Combine

protocol ChatManagerType {
    func requestCommunication(offer: ManagedOffer, receiverPublicKey: String, messagePayload: MessagePayload) -> AnyPublisher<Void, Error>

}

final class ChatManager: ChatManagerType {
    @Inject var chatRepository: ChatRepositoryType
    @Inject var chatService: ChatServiceType

    func requestCommunication(offer: ManagedOffer, receiverPublicKey: String, messagePayload: MessagePayload) -> AnyPublisher<Void, Error> {
        guard let payload = messagePayload.asString else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return chatService
            .requestCommunication(inboxPublicKey: receiverPublicKey, message: payload)
            .flatMap { [chatRepository] _ in
                chatRepository
                    .createChat(requestedOffer: offer, receiverPublicKey: receiverPublicKey, requestMessage: messagePayload.text ?? "")
            }
            .asVoid()
            .eraseToAnyPublisher()
    }
}
