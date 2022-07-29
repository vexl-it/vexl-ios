//
//  InboxRepository.swift
//  vexl
//
//  Created by Adam Salih on 21.07.2022.
//

import UIKit
import Combine
import Network

protocol InboxRepositoryType {

    func createOrUpdateChats(receivedPayloads: [MessagePayload], inbox: ManagedInbox) -> AnyPublisher<Void, Error>

    func deleteChats(recevedPayloads: [MessagePayload], inbox: ManagedInbox) -> AnyPublisher<Void, Error>

    func getInbox(with publicKey: String) -> AnyPublisher<ManagedInbox?, Error>
}

class InboxRepository: InboxRepositoryType {
    @Inject var persistence: PersistenceStoreManagerType
    @Inject var userRepository: UserRepositoryType

    func createOrUpdateChats(receivedPayloads payloads: [MessagePayload], inbox unsafeContextInbox: ManagedInbox) -> AnyPublisher<Void, Error> {
        let payloads = payloads.filter { $0.messageType != .deleteChat && $0.messageType != .messagingRejection }
        guard !payloads.isEmpty else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let isUserInbox = userRepository.user?.profile?.keyPair?.inbox == unsafeContextInbox
        return persistence.insert(context: persistence.newEditContext()) { [weak self, persistence] context -> [ManagedChat] in
            guard let inbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: unsafeContextInbox.objectID) else {
                return []
            }
            return payloads.compactMap { payload in
                let predicate = NSPredicate(format: "receiverKeyPair.publicKey == '\(payload.contactInboxKey)'")
                if let chat = inbox.chats?.filtered(using: predicate).first as? ManagedChat {
                    if chat.messages?.filtered(using: NSPredicate(format: "id == '\(payload.id)'")).first == nil {
                        let message = ManagedMessage(context: context)
                        self?.populateMessage(message: message, chat: chat, payload: payload)
                    }
                    return nil
                }
                let chat = ManagedChat(context: context)
                let message = ManagedMessage(context: context)
                let keyPair = ManagedKeyPair(context: context)
                let profile = ManagedProfile(context: context)

                // creating new chat from receiver request
                profile.avatar = UIImage(named: R.image.profile.avatar.name)?.pngData() // TODO: generate random avatar
                profile.name = Constants.randomName // TODO: generate random name

                keyPair.profile = profile
                keyPair.publicKey = payload.contactInboxKey

                chat.receiverKeyPair = keyPair
                chat.id = UUID().uuidString
                chat.inbox = inbox

                if !isUserInbox, inbox.offers?.count == 1, let offer = inbox.offers?.first(where: { _ in true }) as? ManagedOffer {
                    keyPair.offer = offer
                }

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
        message.time = payload.time
        message.type = payload.messageType
        message.isContact = payload.isFromContact

        chat.lastMessageDate = message.date

        switch message.type {
        case .revealRequest:
            if payload.isFromContact {
                if let imageURL = payload.user?.image, let avatarURL = URL(string: imageURL), let avatar = try? Data(contentsOf: avatarURL) {
                    chat.receiverKeyPair?.profile?.secretAvatar = avatar
                }
                chat.receiverKeyPair?.profile?.secretName = payload.user?.name
            }
        case .revealApproval:
            chat.gotRevealedResponse = true
            chat.isRevealed = true
            if payload.isFromContact {
                if let name = payload.user?.name {
                    chat.receiverKeyPair?.profile?.name = name
                }
                if let imageURL = payload.user?.image, let avatarURL = URL(string: imageURL), let avatar = try? Data(contentsOf: avatarURL) {
                    chat.receiverKeyPair?.profile?.avatar = avatar
                }
            } else {
                chat.receiverKeyPair?.profile?.avatar = chat.receiverKeyPair?.profile?.secretAvatar
                chat.receiverKeyPair?.profile?.name = chat.receiverKeyPair?.profile?.secretName
            }
        case .revealRejected:
            chat.gotRevealedResponse = true
            chat.isRevealed = false
            chat.receiverKeyPair?.profile?.secretName = nil
            chat.receiverKeyPair?.profile?.secretAvatar = nil
        case .messagingRequest:
            chat.isApproved = false
            chat.isRequesting = true
        case .messagingApproval:
            chat.isApproved = true
            chat.isRequesting = false
        case .invalid, .deleteChat, .messagingRejection, .message:
            break
        }
    }

    func getInbox(with publicKey: String) -> AnyPublisher<ManagedInbox?, Error> {
        persistence
            .load(type: ManagedInbox.self, context: persistence.viewContext, predicate: NSPredicate(format: "keyPair.publicKey == '\(publicKey)'"))
            .map(\.first)
            .eraseToAnyPublisher()
    }

    func deleteChats(recevedPayloads payloads: [MessagePayload], inbox unsafeContextInbox: ManagedInbox) -> AnyPublisher<Void, Error> {
        let payloads = payloads.filter { $0.messageType == .deleteChat || $0.messageType == .messagingRejection }
        guard !payloads.isEmpty else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return persistence.delete(context: persistence.viewContext) { [persistence] context -> [ManagedChat] in
            guard let inbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: unsafeContextInbox.objectID) else {
                return []
            }
            return payloads.compactMap { payload in
                let predicate = NSPredicate(format: "receiverKeyPair.publicKey == '\(payload.contactInboxKey)'")
                return inbox.chats?.filtered(using: predicate).first as? ManagedChat
            }
        }
        .asVoid()
        .eraseToAnyPublisher()
    }
}
