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

    mutating func addMessage(_ message: Message) {
        self.messages.append(message)
    }

    static var stub: [ChatMessageGroup] {
        [
            .init(date: Date(), messages: [
                .init(category: .text,
                      isContact: true,
                      text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"),
                .init(category: .text,
                      isContact: false,
                      text: "Vivamus est justo, placerat aliquam velit vitae")
            ]),
            .init(date: Date(), messages: [
                .init(category: .text,
                      isContact: false,
                      text: "Morbi vitae velit ac ex congue molestie" ),
                .init(category: .image,
                      isContact: true,
                      image: R.image.onboarding.testAvatar()!.jpegData(compressionQuality: 0.25)!),
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

extension ChatMessageGroup {

    struct Message: Identifiable, Hashable {
        let id = UUID()
        let text: String?
        let image: Data?
        let previewImage: Data?
        let category: Category
        let isContact: Bool

        init(category: Category, isContact: Bool, text: String? = nil, image: Data? = nil, previewImage: Data? = nil) {
            self.text = text
            self.image = image
            self.category = category
            self.isContact = isContact
            self.previewImage = previewImage
        }

        static func createInput(text: String?, image: Data? = nil, previewImage: Data? = nil) -> Message {
            Message(category: image != nil ? .image : .text,
                    isContact: false,
                    text: text,
                    image: image,
                    previewImage: previewImage)
        }

        static func createIdentityRequest() -> Message {
            Message(category: .sendReveal, isContact: false)
        }

        static func createIdentityResponse() -> Message {
            Message(category: .receiveReveal, isContact: false)
        }

        // swiftlint: disable nesting
        enum Category: Equatable, Hashable {
            case text
            case image
            case sendReveal
            case receiveReveal

            static func == (lhs: Category, rhs: Category) -> Bool {
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
}
