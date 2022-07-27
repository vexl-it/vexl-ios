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

    let id: String
    let text: String?
    let image: Data?
    let previewImage: Data?
    var type: ItemType
    let isContact: Bool

    let imageView: Image

    init(message: ManagedMessage) {
        let itemType: ChatConversationItem.ItemType = {
            switch message.contentType {
            case .text:
                return .text
            case .image:
                return .image
            case .communicationRequestResponse:
                return .start
            case .anonymousRequest:
                return message.isContact ? .receiveIdentityReveal : .requestIdentityReveal
            case .anonymousRequestResponse:
                return message.type == .revealApproval ? .approveIdentityReveal : .rejectIdentityReveal
            case .deleteChat, .communicationRequest, .none:
                return .noContent
            }
        }()

        self.id = message.id ?? UUID().uuidString
        self.text = message.text
        self.type = itemType
        self.isContact = message.isContact
        self.image = message.image?.dataFromBase64
        self.previewImage = message.image?.dataFromBase64(withCompression: Constants.imageCompressionQuality)
        self.imageView = Image(data: previewImage, placeholder: "")
    }

    init(type: ItemType, isContact: Bool, id: String? = nil, text: String? = nil, image: String? = nil) {
        self.id = id ?? UUID().uuidString
        self.text = text
        self.type = type
        self.isContact = isContact
        self.image = image?.dataFromBase64
        self.previewImage = image?.dataFromBase64(withCompression: Constants.imageCompressionQuality)
        self.imageView = Image(data: previewImage, placeholder: "")
    }

    // MARK: - initializer helpers

    static func createInput(text: String?, image: String? = nil) -> ChatConversationItem {
        ChatConversationItem(type: image != nil ? .image : .text,
                             isContact: false,
                             text: text,
                             image: image)
    }

    static func createIdentityRequest() -> ChatConversationItem {
        ChatConversationItem(type: .requestIdentityReveal, isContact: false)
    }

    static func createIdentityResponse() -> ChatConversationItem {
        ChatConversationItem(type: .receiveIdentityReveal, isContact: false)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(text)
        hasher.combine(image)
    }
}

extension Array where Element == ChatConversationItem {
    mutating func updateRevealIdentities(isAccepted: Bool, chatUser: MessagePayload.ChatUser?) {
        let identityItems = self.enumerated()
            .filter { $0.element.type == .receiveIdentityReveal || $0.element.type == .requestIdentityReveal }

        for (index, item) in identityItems {
            var newItem = item
            newItem.type = isAccepted ? .approveIdentityReveal : .rejectIdentityReveal
            self[index] = newItem
        }
    }
}

extension ChatConversationItem {
    enum ItemType: Equatable, Hashable {
        case text
        case image
        case requestIdentityReveal
        case receiveIdentityReveal
        case approveIdentityReveal
        case rejectIdentityReveal
        case start
        case noContent
    }
}
