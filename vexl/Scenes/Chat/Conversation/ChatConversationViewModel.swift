//
//  ChatConversationViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/07/22.
//

import Foundation
import Cleevio
import SwiftUI

final class ChatConversationViewModel: ObservableObject {

    @Inject var inboxManager: InboxManagerType
    @Inject var chatService: ChatServiceType

    @Published var messages: [ChatConversationSection] = []

    var updateContactInformation: ActionSubject<ParsedChatMessage.ChatUser> = .init()

    @Published var username: String = Constants.randomName
    @Published var avatar: Data?

    var avatarImage: Image
    var rejectImage: Image

    private let inboxKeys: ECCKeys
    private let receiverPublicKey: String
    private let cancelBag: CancelBag = .init()

    init(inboxKeys: ECCKeys, receiverPublicKey: String) {
        self.inboxKeys = inboxKeys
        self.receiverPublicKey = receiverPublicKey
        self.avatarImage = Image(R.image.marketplace.defaultAvatar.name)
        self.rejectImage = Image(R.image.chat.rejectReveal.name)
        setupInboxManagerBinding()
        setupInitialMessageFetching()
    }

    func updateContact(name: String, avatar: String?) {
        avatarImage = Image(data: avatar?.dataFromBase64, placeholder: R.image.marketplace.defaultAvatar.name)
        username = name
        self.avatar = avatar?.dataFromBase64
    }

    private func setupInitialMessageFetching() {
        chatService
            .getStoredChatMessages(inboxPublicKey: inboxKeys.publicKey, contactPublicKey: receiverPublicKey)
            .materialize()
            .compactMap(\.value)
            .withUnretained(self)
            .sink { owner, messages in
                owner.showChatMessages(messages, filter: [])
            }
            .store(in: cancelBag)
    }

    private func setupInboxManagerBinding() {
        inboxManager
            .completedSyncing
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case let .success(messages):
                    let messagesForInbox = messages.filter {
                        $0.inboxKey == owner.inboxKeys.publicKey && $0.contactInboxKey == owner.receiverPublicKey
                    }
                    owner.showChatMessages(messagesForInbox, filter: [.revealRejected, .revealApproval])
                    owner.updateRevealedUser(messages: messages)
                case .failure:
                    // TODO: - show some alert
                    break
                }
            }
            .store(in: cancelBag)
    }

    private func showChatMessages(_ messages: [ParsedChatMessage], filter: [MessageType]) {
        let conversationItems = messages.compactMap { message -> ChatConversationItem? in

            guard !filter.contains(message.messageType) else {
                return nil
            }

            var itemType: ChatConversationItem.ItemType

            switch message.contentType {
            case .text:
                itemType = .text
            case .image:
                itemType = .image
            case .communicationRequestResponse:
                itemType = .start
            case .anonymousRequest:
                itemType = message.isFromContact ? .receiveIdentityReveal : .requestIdentityReveal
            case .anonymousRequestResponse:
                itemType = message.messageType == .revealApproval ? .approveIdentityReveal : .rejectIdentityReveal
            case .deleteChat, .communicationRequest, .none:
                itemType = .noContent
            }

            return ChatConversationItem(type: itemType,
                                        isContact: message.isFromContact,
                                        text: message.text,
                                        image: message.image)
        }
        self.messages.appendItems(conversationItems)
    }

    func updateDisplayedRevealMessages(isAccepted: Bool, user: ParsedChatMessage.ChatUser?) {
        if let user = user, isAccepted {
            messages.updateRevealIdentitiesItems(isAccepted: isAccepted, chatUser: user)
        } else {
            messages.updateRevealIdentitiesItems(isAccepted: isAccepted, chatUser: user)
        }
    }

     private func updateRevealedUser(messages: [ParsedChatMessage]) {
        if let revealMessage = messages.first(where: { $0.messageType == .revealApproval }),
           let user = revealMessage.user {
            updateContact(name: user.name, avatar: user.image)
            updateDisplayedRevealMessages(isAccepted: true, user: user)
            updateContactInformation.send(user)
        } else if messages.contains(where: { $0.messageType == .revealRejected }) {
            updateDisplayedRevealMessages(isAccepted: false, user: nil)
        }
    }
}
