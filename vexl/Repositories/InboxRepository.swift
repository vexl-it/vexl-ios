//
//  InboxRepository.swift
//  vexl
//
//  Created by Adam Salih on 21.07.2022.
//

import Foundation
import Combine
import Network

protocol InboxRepositoryType {

    func createOrUpdateChats(receivedPayloads: [MessagePayload], inbox: ManagedInbox) -> AnyPublisher<Void, Error>

    func deleteChats(recevedPayloads: [MessagePayload], inbox: ManagedInbox) -> AnyPublisher<Void, Error>
}

class InboxRepository: InboxRepositoryType {
    @Inject var persistence: PersistenceStoreManagerType

    func createOrUpdateChats(receivedPayloads payloads: [MessagePayload], inbox unsafeContextInbox: ManagedInbox) -> AnyPublisher<Void, Error> {
        persistence.insert(context: persistence.viewContext) { [weak self, persistence] context -> [ManagedChat] in
            guard let inbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: unsafeContextInbox.objectID) else {
                return []
            }
            return payloads
                .filter { $0.messageType != .deleteChat && $0.messageType != .messagingRejection }
                .compactMap { payload in
                    let predicate = NSPredicate(format: "receiverKeyPair.publicKey == '\(payload.receiverPublicKey)'")
                    if let chat = inbox.chats?.filtered(using: predicate).first as? ManagedChat {
                        if chat.messages?.filtered(using: NSPredicate(format: "id == '\(payload.id)'")).first == nil {
                            let message = ManagedMessage(context: context)
                            self?.populateMessage(message: message, chat: chat, payload: payload)
                        }
                        return nil
                    }
                    let chat = ManagedChat(context: context)
                    let message = ManagedMessage(context: context)

                    chat.id = UUID().uuidString
                    chat.inbox = inbox
                    self?.populateMessage(message: message, chat: chat, payload: payload)

                    return chat
                }
        }
        .asVoid()
        .eraseToAnyPublisher()
    }

    private func populateMessage(message: ManagedMessage, chat: ManagedChat, payload: MessagePayload) {
        message.chat = chat
        message.text = payload.text
        message.image = payload.image
        message.contentType = payload.contentType
        message.time = payload.time
        message.type = payload.messageType
        message.isContact = payload.isFromContact

        chat.lastMessageDate = message.date

        switch message.type {
        case .revealRequest:
            break // TODO: set request flag
        case .revealApproval:
            break // TODO: set request flag
        case .revealRejected:
            break // TODO: set request flag
        case .messagingRequest:
            chat.isApproved = false
            chat.isRequesting = false
        case .messagingApproval:
            chat.isApproved = true
            chat.isRequesting = false
        case .invalid, .deleteChat, .messagingRejection, .message:
            break
        }
    }

    func deleteChats(recevedPayloads payloads: [MessagePayload], inbox unsafeContextInbox: ManagedInbox) -> AnyPublisher<Void, Error> {
        persistence.delete(context: persistence.viewContext) { [persistence] context -> [ManagedChat] in
            guard let inbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: unsafeContextInbox.objectID) else {
                return []
            }
            return payloads
                .filter { $0.messageType == .deleteChat || $0.messageType == .messagingRejection }
                .compactMap { payload in
                    let predicate = NSPredicate(format: "receiverKeyPair.publicKey == '\(payload.contactInboxKey)'")
                    return inbox.chats?.filtered(using: predicate).first as? ManagedChat
                }
        }
        .asVoid()
        .eraseToAnyPublisher()
    }
}
