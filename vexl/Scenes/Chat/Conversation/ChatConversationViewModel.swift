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

    var updateContactInformation: ActionSubject<MessagePayload.ChatUser> = .init()
    var displayExpandedImage: ActionSubject<Data> = .init()
    var identityRevealResponse: ActionSubject<Void> = .init()

    var action: ActionSubject<UserAction> = .init()

    @Published var avatarImage: Image = Image(R.image.marketplace.defaultAvatar.name)
    var rejectImage: Image = Image(R.image.chat.rejectReveal.name)

    private let chat: ManagedChat
    private let cancelBag: CancelBag = .init()

    init(chat: ManagedChat) {
        self.chat = chat

        let profile = chat.receiverKeyPair?.profile

        let avatarPublisher = profile?.publisher(for: \.avatar).share()
        avatarPublisher?.assign(to: &$avatar)
        avatarPublisher?.map { Image(data: $0, placeholder: R.image.marketplace.defaultAvatar.name) }.assign(to: &$avatarImage)
        profile?.publisher(for: \.name).filterNil().assign(to: &$username)

        setupInboxManagerBinding()
        setupActionBindings()
    }

    func updateContact(name: String, avatar: String?) {
        avatarImage = Image(data: avatar?.dataFromBase64, placeholder: R.image.marketplace.defaultAvatar.name)
        username = name
        self.avatar = avatar?.dataFromBase64
    }

    func updateDisplayedRevealMessages(isAccepted: Bool, user: MessagePayload.ChatUser?) {
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

    private func setupInboxManagerBinding() {
        chat.publisher(for: \.messages)
            .map { $0?.sortedArray(using: [ NSSortDescriptor(key: "time", ascending: true) ]) }
            .compactMap { $0 as? [ManagedMessage] }
            .withUnretained(self)
            .sink(receiveValue: { owner, messages in
                owner.showChatMessages(messages, filter: [.revealRejected, .revealApproval])
            })
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
                guard let section = owner.messages.first(where: { $0.id == ids.sectionId }),
                      let message = section.messages.first(where: { $0.id == ids.messageId }) else {
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

    private func showChatMessages(_ messages: [ManagedMessage], filter: [MessageType]) {
        let conversationItems = messages.compactMap { message -> ChatConversationItem? in

            guard !filter.contains(message.type) else {
                return nil
            }
            return ChatConversationItem(message: message)
        }
        self.messages = [ChatConversationSection(date: Date(), messages: conversationItems)]
    }

     private func updateRevealedUser(messages: [MessagePayload]) {
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
