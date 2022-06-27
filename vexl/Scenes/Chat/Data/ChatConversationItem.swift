//
//  ChatConversationItem.swift
//  vexl
//
//  Created by Diego Espinoza on 20/06/22.
//

import Foundation
import SwiftUI

/// Individual conversation element that will be displayed in the Chat.
/// It will be a bubble containing a text, image or be the request/response for identity reveal

struct ChatConversationItem: Identifiable, Hashable {

    let id = UUID()
    let text: String?
    let image: Data?
    let previewImage: Data?
    let type: ItemType
    let isContact: Bool

    let imageView: Image

    init(type: ItemType, isContact: Bool, text: String? = nil, image: Data? = nil, previewImage: Data? = nil) {
        self.text = text
        self.image = image
        self.type = type
        self.isContact = isContact
        self.previewImage = previewImage
        self.imageView = Image(data: previewImage, placeholder: "")
    }

    // MARK: - initializer helpers

    static func createInput(text: String?, image: Data? = nil, previewImage: Data? = nil) -> ChatConversationItem {
        ChatConversationItem(type: image != nil ? .image : .text,
                             isContact: false,
                             text: text,
                             image: image,
                             previewImage: previewImage)
    }

    static func createIdentityRequest() -> ChatConversationItem {
        ChatConversationItem(type: .sendReveal, isContact: false)
    }

    static func createIdentityResponse() -> ChatConversationItem {
        ChatConversationItem(type: .receiveReveal, isContact: false)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
        hasher.combine(image)
    }
}

extension ChatConversationItem {
    enum ItemType: Equatable, Hashable {
        case text
        case image
        case sendReveal
        case receiveReveal
        case start
    }
}
