//
//  ChatMessageGroup.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import Foundation

struct ChatMessageGroup: Identifiable, Hashable {

    let id = UUID()
    let date: Date
    var messages: [Message]

    struct Message: Identifiable, Hashable {
        let id = UUID()
        let text: String
        let isContact: Bool
    }

    mutating func addMessage(_ message: Message) {
        self.messages.append(message)
    }

    static var stub: [ChatMessageGroup] {
        [
            .init(date: Date(), messages: [
                .init(text: "Hello there", isContact: true),
                .init(text: "General Kenobi", isContact: false)
            ]),
            .init(date: Date(), messages: [
                .init(text: "Haha you are a bold one", isContact: false)
            ])
        ]
    }
}

extension Array where Element == ChatMessageGroup {
    mutating func appendMessage(_ message: ChatMessageGroup.Message) {
        if let lastGroup = self.last {
            var updatedGroup = lastGroup
            updatedGroup.addMessage(message)
            self[self.count - 1] = updatedGroup
        } else {
            let newGroup = ChatMessageGroup(date: Date(),
                                            messages: [message])
            self.append(newGroup)
        }
    }
}
