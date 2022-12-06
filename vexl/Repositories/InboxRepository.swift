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

    ///  Creates or updates chats with message payloads in given inbox
    ///   - Parameter receivedPayloads: Array of message payloads and their publicID from its public part
    ///   - Parameter inbox: CoreData managed object representing inbox
    ///
    ///   - Returns: Publisher which emits void on succes and error on error
    func createOrUpdateChats(receivedPayloads: [(publicID: Int, payload: MessagePayload)], inbox: ManagedInbox) -> AnyPublisher<Void, Error>

    func deleteChats(receivedPayloads: [MessagePayload], inbox: ManagedInbox) -> AnyPublisher<Void, Error>

    func getInbox(with publicKey: String) -> AnyPublisher<ManagedInbox?, Error>

    func setInboxChatsUserLeft(receivedPayloads: [MessagePayload], inbox: ManagedInbox) -> AnyPublisher<Bool, Error>
}

class InboxRepository: InboxRepositoryType {
    @Inject var persistence: PersistenceStoreManagerType
    @Inject var userRepository: UserRepositoryType

    func createOrUpdateChats(receivedPayloads payloads: [(publicID: Int, payload: MessagePayload)], inbox unsafeContextInbox: ManagedInbox) -> AnyPublisher<Void, Error> {
        let payloads = payloads.filter { $0.payload.messageType != .messagingRejection }
        guard !payloads.isEmpty else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let isUserInbox = userRepository.user?.profile?.keyPair?.inbox == unsafeContextInbox
        return persistence.insert(context: persistence.newEditContext()) { [weak self, persistence] context -> [ManagedChat] in
            guard let inbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: unsafeContextInbox.objectID) else {
                return []
            }
            return payloads.compactMap { publicID, payload in
                let predicate = NSPredicate(format: "receiverKeyPair.publicKey == '\(payload.contactInboxKey)'")
                if let chat = inbox.chats?.filtered(using: predicate).first as? ManagedChat {
                    if chat.messages?.filtered(using: NSPredicate(format: "id == '\(payload.id)'")).first == nil {
                        let message = ManagedMessage(context: context)
                        self?.populateMessage(id: publicID, message: message, chat: chat, payload: payload)
                    }
                    return nil
                }
                let chat = ManagedChat(context: context)
                let message = ManagedMessage(context: context)
                let keyPair = ManagedKeyPair(context: context)
                let profile = ManagedProfile(context: context)

                // creating new chat from receiver request
                profile.avatar = UIImage(named: R.image.profile.avatar.name)?.pngData() // TODO: generate random avatar
                profile.generateRandomName()

                keyPair.profile = profile
                keyPair.publicKey = payload.contactInboxKey

                chat.receiverKeyPair = keyPair
                chat.id = UUID().uuidString
                chat.inbox = inbox

                if !isUserInbox, inbox.offers?.count == 1, let offer = inbox.offers?.first(where: { _ in true }) as? ManagedOffer {
                    keyPair.userOffer = offer
                }

                self?.populateMessage(id: publicID, message: message, chat: chat, payload: payload)

                return chat
            }
        }
        .asVoid()
        .eraseToAnyPublisher()
    }

    private func populateMessage(id: Int, message: ManagedMessage, chat: ManagedChat, payload: MessagePayload) {
        message.publicID = Int64(id)
        message.chat = chat
        message.text = payload.text
        message.image = payload.image
        message.time = payload.time
        message.type = payload.messageType
        message.isContact = payload.isFromContact

        chat.lastMessageDate = message.date

        switch message.type {
        case .revealRequest:
            chat.gotRevealedResponse = false
            chat.isRevealed = false
            chat.showIdentityRequest = false
            chat.shouldDisplayRevealBanner = true
            if payload.isFromContact {
                if let imageURL = payload.user?.imageURL, let avatarURL = URL(string: imageURL), let avatar = try? Data(contentsOf: avatarURL) {
                    chat.receiverKeyPair?.profile?.realAvatarBeforeReveal = avatar
                    chat.receiverKeyPair?.profile?.realAvatarURLBeforeReveal = imageURL
                } else if let imageData = payload.user?.imageData, let imageString = imageData.dataFromBase64 {
                    chat.receiverKeyPair?.profile?.realAvatarBeforeReveal = imageString
                    chat.receiverKeyPair?.profile?.realAvatarURLBeforeReveal = nil
                }
                chat.receiverKeyPair?.profile?.realNameBeforeReveal = payload.user?.name
            }
        case .revealApproval:
            chat.gotRevealedResponse = true
            chat.isRevealed = true
            chat.showIdentityRequest = false
            let requestMessage = getLastIdentityRequestMessage(chat: chat)
            requestMessage?.isRevealed = true
            requestMessage?.hasRevealResponse = true

            if payload.isFromContact {
                if let name = payload.user?.name {
                    chat.receiverKeyPair?.profile?.name = name
                }
                if let imageURL = payload.user?.imageURL, let avatarURL = URL(string: imageURL), let avatar = try? Data(contentsOf: avatarURL) {
                    chat.receiverKeyPair?.profile?.avatar = avatar
                    chat.receiverKeyPair?.profile?.avatarURL = imageURL
                } else if let imageData = payload.user?.imageData, let imageString = imageData.dataFromBase64 {
                    chat.receiverKeyPair?.profile?.avatar = imageString
                    chat.receiverKeyPair?.profile?.avatarURL = nil
                }
            } else {
                chat.receiverKeyPair?.profile?.avatarURL = chat.receiverKeyPair?.profile?.realAvatarURLBeforeReveal
                chat.receiverKeyPair?.profile?.avatar = chat.receiverKeyPair?.profile?.realAvatarBeforeReveal
                chat.receiverKeyPair?.profile?.name = chat.receiverKeyPair?.profile?.realNameBeforeReveal
            }
        case .revealRejected:
            chat.showIdentityRequest = true
            chat.gotRevealedResponse = true
            chat.isRevealed = false

            let requestMessage = getLastIdentityRequestMessage(chat: chat)
            requestMessage?.isRevealed = false
            requestMessage?.hasRevealResponse = true

            chat.receiverKeyPair?.profile?.realNameBeforeReveal = nil
            chat.receiverKeyPair?.profile?.realAvatarBeforeReveal = nil
            chat.receiverKeyPair?.profile?.realAvatarURLBeforeReveal = nil
        case .messagingRequest:
            chat.isApproved = false
            chat.isRequesting = true
        case .messagingApproval:
            chat.isApproved = true
            chat.isRequesting = false
        case .invalid, .deleteChat, .messagingRejection, .message, .blockChat:
            break
        }
    }

    private func getLastIdentityRequestMessage(chat: ManagedChat) -> ManagedMessage? {
        let messages = chat.messages?.filtered(
            using: NSPredicate(format: "typeRawType == '\(MessageType.revealRequest.rawValue)'")
        ) as? Set<ManagedMessage>
        return messages?.sorted(by: { $0.time > $1.time }).first
    }

    func getInbox(with publicKey: String) -> AnyPublisher<ManagedInbox?, Error> {
        persistence
            .load(
                type: ManagedInbox.self,
                context: persistence.viewContext,
                predicate: NSPredicate(format: "keyPair.publicKey == '\(publicKey)'")
            )
            .map(\.first)
            .eraseToAnyPublisher()
    }

    func deleteChats(receivedPayloads payloads: [MessagePayload], inbox unsafeContextInbox: ManagedInbox) -> AnyPublisher<Void, Error> {
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
        .eraseToAnyPublisher()
    }

    func setInboxChatsUserLeft(receivedPayloads payloads: [MessagePayload], inbox unsafeContextInbox: ManagedInbox) -> AnyPublisher<Bool, Error> {
        let payloads = payloads.filter { $0.messageType == .deleteChat || $0.messageType == .messagingRejection }
        guard !payloads.isEmpty else {
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return persistence.update(context: persistence.viewContext) { [persistence] context in
            guard let inbox = persistence.loadSyncroniously(type: ManagedInbox.self, context: context, objectID: unsafeContextInbox.objectID),
                  let chatSet = inbox.chats
            else {
                return
            }
            payloads
                .flatMap { payload -> [ManagedChat] in
                    let predicate = NSPredicate(format: "receiverKeyPair.publicKey == '\(payload.contactInboxKey)'")
                    let receivedChatSet = chatSet.filtered(using: predicate) as? Set<ManagedChat> ?? .init()
                    return Array(receivedChatSet)
                }
                .forEach { chat in
                    chat.hasChatEnded = true
                }
        }
        .map { true }
        .eraseToAnyPublisher()
    }
}
