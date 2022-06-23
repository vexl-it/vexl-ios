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
                      image: R.image.onboarding.testAvatar()!.base64!),
                .init(type: .sendReveal, isContact: false),
                .init(type: .receiveReveal, isContact: false)
            ])
        ]
    }
}
