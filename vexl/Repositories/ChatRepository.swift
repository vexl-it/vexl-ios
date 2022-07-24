//
//  ChatRepository.swift
//  vexl
//
//  Created by Adam Salih on 21.07.2022.
//

import Foundation
import Combine

protocol ChatRepositoryType {
    func createChat(requestedOffer: ManagedOffer, receiverPublicKey: String, requestMessage: String) -> AnyPublisher<ManagedChat, Error>
}

class ChatRepository: ChatRepositoryType {
    @Inject var persistence: PersistenceStoreManagerType

    func createChat(requestedOffer: ManagedOffer, receiverPublicKey: String, requestMessage: String) -> AnyPublisher<ManagedChat, Error> {
        let context = persistence.newEditContext()
        guard let offer = persistence.loadSyncroniously(type: ManagedOffer.self, context: context, objectID: requestedOffer.objectID) else {
            return Fail(error: PersistenceError.insufficientData)
                .eraseToAnyPublisher()
        }
        return persistence.insert(context: context) { context in

            let chat = ManagedChat(context: context)
            let message = ManagedMessage(context: context)

            message.chat = chat
            message.text = requestMessage
            message.type = .messagingRequest
            message.contentType = .communicationRequest
            message.time = Date().timeIntervalSince1970
            message.contentType = .anonymousRequest

            chat.id = UUID().uuidString
            chat.receiverKeyPair = offer.receiverPublicKey
            chat.inbox = offer.inbox

            chat.lastMessageDate = message.date

            return chat
        }
    }
}
