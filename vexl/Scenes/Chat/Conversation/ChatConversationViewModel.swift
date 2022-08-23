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
        case imageTapped(image: Data?)
    }

    @Inject var inboxManager: InboxManagerType
    @Inject var chatService: ChatServiceType

    @Fetched(fetchImmediately: false, sortDescriptors: [ NSSortDescriptor(key: "time", ascending: true) ])
    var fetchedMessages: [ManagedMessage]

    @Published var messages: [ChatConversationSection] = []
    @Published var lastMessageID: String?
    @Published var username: String = L.generalAnonymous()
    @Published var avatar: Data?

    var updateContactInformation: ActionSubject<MessagePayload.ChatUser> = .init()
    var displayExpandedImage: ActionSubject<Data> = .init()
    var identityRevealResponseTap: ActionSubject<Void> = .init()

    var action: ActionSubject<UserAction> = .init()

    @Published var avatarImage: Image = Image(R.image.marketplace.defaultAvatar.name)
    var rejectImage: Image = Image(R.image.chat.rejectReveal.name)

    private let chat: ManagedChat
    private let cancelBag: CancelBag = .init()

    init(chat: ManagedChat) {
        self.chat = chat

        setupDataBinding()
        setupActionBindings()
    }

    private func setupDataBinding() {
        let profile = chat.receiverKeyPair?.profile
        let avatarPublisher = profile?.publisher(for: \.avatarData).map { _ in profile?.avatar }.share()

        avatar = profile?.avatar
        avatarImage = Image(data: profile?.avatar, placeholder: R.image.marketplace.defaultAvatar.name)

        avatarPublisher?
            .assign(to: &$avatar)
        avatarPublisher?
            .map { Image(data: $0, placeholder: R.image.marketplace.defaultAvatar.name) }
            .assign(to: &$avatarImage)
        profile?
            .publisher(for: \.name)
            .filterNil()
            .assign(to: &$username)

        $fetchedMessages.load(predicate: NSPredicate(format: """
            chat == %@
        """, chat
        ))

        $fetchedMessages.publisher
            .map(\.objects)
            .map { $0.filter { $0.type != .revealRejected && $0.type != .revealApproval } }
            .map { $0.map(ChatConversationItem.init) }
            .map { [ ChatConversationSection(date: Date(), messages: $0) ] }
            .assign(to: &$messages)

        $messages
            .map(\.last?.messages.last?.id)
            .assign(to: &$lastMessageID)
    }

    private func setupActionBindings() {
        action
            .compactMap { action -> Data? in
                guard case let .imageTapped(image) = action else { return nil }
                return image
            }
            .subscribe(displayExpandedImage)
            .store(in: cancelBag)
    }

    private func filterMessaged(_ messages: [ManagedMessage], filter: [MessageType]) -> [ChatConversationSection] {
        let filteredMessages = messages
            .filter { !filter.contains($0.type) }
            .map { ChatConversationItem(message: $0) }
        let section = ChatConversationSection(date: Date(), messages: filteredMessages)
        return [section]
    }
}
