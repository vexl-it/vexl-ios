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
        case open(url: URL)
    }

    @Inject var inboxManager: InboxManagerType
    @Inject var chatService: ChatServiceType

    @Fetched(fetchImmediately: false, sortDescriptors: [
        NSSortDescriptor(key: "publicID", ascending: true),
        NSSortDescriptor(key: "time", ascending: true)
    ])
    var fetchedMessages: [ManagedMessage]

    @Published var messages: [ChatConversationSection] = []
    @Published var lastMessageID: String?
    @Published var forceScrollToBottom = false
    @Published var username: String = L.generalAnonymous()
    @Published var avatar: Data?

    var updateContactInformation: ActionSubject<MessagePayload.ChatUser> = .init()
    var displayExpandedImage: ActionSubject<Data> = .init()
    var urlTap: ActionSubject<URL> = .init()
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
            .delay(for: 0.25, scheduler: RunLoop.main)
            .assign(to: &$lastMessageID)

        NotificationCenter
            .default
            .publisher(for: UIWindow.keyboardDidShowNotification)
            .asVoid()
            .withUnretained(self)
            .sink { owner in
                owner.lastMessageID = owner.lastMessageID
            }
            .store(in: cancelBag)
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
            .compactMap { action -> URL? in
                guard case let .open(url) = action else { return nil }
                return url
            }
            .subscribe(urlTap)
            .store(in: cancelBag)
    }
}
