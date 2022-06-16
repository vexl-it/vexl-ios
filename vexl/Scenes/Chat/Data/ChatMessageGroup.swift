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
        let category: Category
        let isContact: Bool

        enum Category: Equatable, Hashable {
            case text(text: String)
            case image(image: Data, text: String?)
            case sendReveal
            case receiveReveal

            static func ==(lhs: Category, rhs: Category) -> Bool {
                switch (lhs, rhs) {
                case (.text, .text):
                    return true
                case (.image, .image):
                    return true
                case (.sendReveal, .sendReveal):
                    return true
                case (.receiveReveal, .receiveReveal):
                    return true
                default:
                    return false
                }
            }
        }
    }

    mutating func addMessage(_ message: Message) {
        self.messages.append(message)
    }

    static var stub: [ChatMessageGroup] {
        [
            .init(date: Date(), messages: [
                .init(category: .text(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"),
                      isContact: true),
                .init(category: .text(text: "Vivamus est justo, placerat aliquam velit vitae"),
                      isContact: false)
            ]),
            .init(date: Date(), messages: [
                .init(category: .text(text: "Morbi vitae velit ac ex congue molestie"),
                      isContact: false),
                .init(category: .image(image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.5)!, text: nil),
                      isContact: true),
                .init(category: .sendReveal, isContact: false),
                .init(category: .receiveReveal, isContact: false)
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
