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

    enum UserAction: Equatable {
        case imageTapped(sectionId: String, messageId: String)
        case revealTapped
    }

    @Inject var inboxManager: InboxManagerType
    @Inject var chatService: ChatServiceType

    @Published var messages: [ChatConversationSection] = []
    @Published var username: String = Constants.randomName
    @Published var avatar: Data?

    var updateContactInformation: ActionSubject<ParsedChatMessage.ChatUser> = .init()
    var displayExpandedImage: ActionSubject<Data> = .init()
    var identityRevealResponse: ActionSubject<Void> = .init()

    var action: ActionSubject<UserAction> = .init()

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
        setupActionBindings()
    }

    func updateContact(name: String, avatar: String?) {
        avatarImage = Image(data: avatar?.dataFromBase64, placeholder: R.image.marketplace.defaultAvatar.name)
        username = name
        self.avatar = avatar?.dataFromBase64
    }

    func updateDisplayedRevealMessages(isAccepted: Bool, user: ParsedChatMessage.ChatUser?) {
        if let user = user, isAccepted {
            messages.updateRevealIdentitiesItems(isAccepted: isAccepted, chatUser: user)
        } else {
            messages.updateRevealIdentitiesItems(isAccepted: isAccepted, chatUser: user)
        }
    }

    func addMessage(_ message: String, image: Data?) {
        messages.appendItem(.createInput(text: message,
                                         image: image?.base64EncodedString()))
    }

    func addIdentityRequest() {
        messages.appendItem(.createIdentityRequest())
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

    private func setupActionBindings() {
        action
            .compactMap { action -> (sectionId: String, messageId: String)? in
                if case let .imageTapped(sectionId, messageId) = action { return (sectionId: sectionId, messageId: messageId) }
                return nil
            }
            .withUnretained(self)
            .compactMap { owner, ids -> Data? in
                guard let section = owner.messages.first(where: { $0.id.uuidString == ids.sectionId }),
                      let message = section.messages.first(where: { $0.id.uuidString == ids.messageId }) else {
                          return nil
                      }
                return message.image
            }
            .subscribe(displayExpandedImage)
            .store(in: cancelBag)

        action
            .filter { $0 == .revealTapped }
            .asVoid()
            .subscribe(identityRevealResponse)
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
