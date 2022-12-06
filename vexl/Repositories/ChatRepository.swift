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
    func setBlockChat(chat: ManagedChat, isBlocked: Bool) -> AnyPublisher<ManagedChat, Error>
    func setDisplayRevealBanner(chat: ManagedChat, shouldDisplay: Bool) -> AnyPublisher<ManagedChat, Error>
    func setChatEnded(chat: ManagedChat, ended: Bool) -> AnyPublisher<ManagedChat, Error>
    func getChat(inboxPK: String, senderPK: String) -> AnyPublisher<ManagedChat?, Error>
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
            message.time = Date().timeIntervalSince1970

            chat.id = UUID().uuidString
            chat.receiverKeyPair = offer.receiversPublicKey
            chat.inbox = offer.inbox

            chat.lastMessageDate = message.date

            return chat
        }
    }

    func setBlockChat(chat: ManagedChat, isBlocked: Bool) -> AnyPublisher<ManagedChat, Error> {
        let context = persistence.newEditContext()
        return persistence.update(context: context) { [chat] _ in
            chat.isBlocked = isBlocked
            return chat
        }
    }

    func setDisplayRevealBanner(chat: ManagedChat, shouldDisplay: Bool) -> AnyPublisher<ManagedChat, Error> {
        let context = persistence.newEditContext()
        return persistence.update(context: context) { [chat] _ in
            chat.shouldDisplayRevealBanner = shouldDisplay
            return chat
        }
    }

    func setChatEnded(chat: ManagedChat, ended: Bool) -> AnyPublisher<ManagedChat, Error> {
        let context = persistence.newEditContext()
        return persistence.update(context: context) { [chat] _ in
            chat.hasChatEnded = ended
            return chat
        }
    }

    func getChat(inboxPK: String, senderPK: String) -> AnyPublisher<ManagedChat?, Error> {
        persistence
            .load(
                type: ManagedChat.self,
                context: persistence.viewContext,
                predicate: NSPredicate(
                    format: "inbox.keyPair.publicKey == '\(inboxPK)' AND receiverKeyPair.publicKey == '\(senderPK)'")
            )
            .map(\.first)
            .eraseToAnyPublisher()
    }
}
