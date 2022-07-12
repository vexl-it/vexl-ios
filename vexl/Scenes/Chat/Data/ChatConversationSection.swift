//
//  ChatMessageGroup.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import Foundation

/// Struct used for grouping the conversation elements of each user
/// the grouping will be done using the date

struct ChatConversationSection: Identifiable, Hashable {

    let id = UUID()
    let date: Date
    var messages: [ChatConversationItem]

    mutating func addItem(_ message: ChatConversationItem) {
        self.messages.append(message)
    }

    mutating func addItems(_ messages: [ChatConversationItem]) {
        self.messages.append(contentsOf: messages)
    }

    mutating func updateRevealIdentitiesItems(isAccepted: Bool, chatUser: ParsedChatMessage.ChatUser?) {
        messages.updateRevealIdentities(isAccepted: isAccepted, chatUser: chatUser)
    }
}

extension Array where Element == ChatConversationSection {
    mutating func appendItem(_ message: ChatConversationItem) {
        if let lastGroup = self.last {
            var updatedGroup = lastGroup
            updatedGroup.addItem(message)
            self[self.count - 1] = updatedGroup
        } else {
            let newGroup = ChatConversationSection(date: Date(),
                                                   messages: [message])
            self.append(newGroup)
        }
    }

    mutating func appendItems(_ messages: [ChatConversationItem]) {
        if let lastGroup = self.last {
            var updatedGroup = lastGroup
            updatedGroup.addItems(messages)
            self[self.count - 1] = updatedGroup
        } else {
            let newGroup = ChatConversationSection(date: Date(),
                                                   messages: messages)
            self.append(newGroup)
        }
    }

    mutating func updateRevealIdentitiesItems(isAccepted: Bool, chatUser: ParsedChatMessage.ChatUser?) {
        for (index, section) in self.enumerated() {
            var newSection = section
            newSection.updateRevealIdentitiesItems(isAccepted: isAccepted, chatUser: chatUser)
            self[index] = newSection
        }
    }
}

extension ChatConversationSection {
    static var stub: [ChatConversationSection] {
        [
            .init(date: Date(), messages: [
                .init(type: .start, isContact: false, text: nil, image: nil)
            ]),
            .init(date: Date(), messages: [
                .init(type: .text,
                      isContact: true,
                      text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"),
                .init(type: .text,
                      isContact: false,
                      text: "Vivamus est justo, placerat aliquam velit vitae")
            ]),
            .init(date: Date(), messages: [
                .init(type: .text,
                      isContact: false,
                      text: "Morbi vitae velit ac ex congue molestie" ),
                .init(type: .image,
                      isContact: true,
                      image: R.image.onboarding.testAvatar()!.base64EncodedString!),
                .init(type: .requestIdentityReveal, isContact: false),
                .init(type: .receiveIdentityReveal, isContact: false)
            ])
        ]
    }
}
