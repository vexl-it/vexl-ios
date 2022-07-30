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
        case revealTapped
    }

    @Inject var inboxManager: InboxManagerType
    @Inject var chatService: ChatServiceType

    @Fetched(fetchImmediately: false, sortDescriptors: [ NSSortDescriptor(key: "time", ascending: true) ])
    var fetchedMessages: [ManagedMessage]

    @Published var messages: [ChatConversationSection] = []
    @Published var username: String = L.generalAnonymous()
    @Published var avatar: Data?

    var updateContactInformation: ActionSubject<MessagePayload.ChatUser> = .init()
    var displayExpandedImage: ActionSubject<Data> = .init()
    var identityRevealResponseTap: ActionSubject<Void> = .init()
    var identityRevealResponseReceived: ActionSubject<Void> = .init()

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

        avatarPublisher?
            .assign(to: &$avatar)
        avatarPublisher?
            .map { Image(data: $0, placeholder: R.image.marketplace.defaultAvatar.name) }
            .assign(to: &$avatarImage)
        profile?
            .publisher(for: \.name).filterNil().assign(to: &$username)

        $fetchedMessages.load(predicate: NSPredicate(format: """
            chat == %@
            AND typeRawType != '\(MessageType.revealRejected.rawValue)'
            AND typeRawType != '\(MessageType.revealApproval.rawValue)'
        """, chat
        ))

        $fetchedMessages.publisher
            .map(\.objects)
            .map { $0.map(ChatConversationItem.init) }
            .map { [ ChatConversationSection(date: Date(), messages: $0) ] }
            .assign(to: &$messages)
    }

    private func setupActionBindings() {
        action
            .compactMap { action -> Data? in
                guard case let .imageTapped(image) = action else { return nil }
                return image
            }
            .subscribe(displayExpandedImage)
            .store(in: cancelBag)

        action
            .filter { $0 == .revealTapped }
            .asVoid()
            .subscribe(identityRevealResponseTap)
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
