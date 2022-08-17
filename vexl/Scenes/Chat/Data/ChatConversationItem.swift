//
//  ChatConversationItem.swift
//  vexl
//
//  Created by Diego Espinoza on 20/06/22.
//

import Combine
import Foundation
import SwiftUI

/// Individual conversation element that will be displayed in the Chat.
/// It will be a bubble containing a text, image or be the request/response for identity reveal

final class ChatConversationItem: Identifiable, Hashable, ObservableObject {

    @Published var type: ItemType

    let id: String
    let text: String?
    let image: Data?
    let previewImage: Data?
    let isContact: Bool

    let imageView: Image

    init(message: ManagedMessage) {
        let itemType: ChatConversationItem.ItemType = {
            switch message.type {
            case .message:
                return .text
            case .messagingApproval:
                return .start
            case .revealRequest:
                return message.isContact ? .receiveIdentityReveal : .requestIdentityReveal
            case .revealApproval:
                return .approveIdentityReveal
            case .revealRejected:
                return .rejectIdentityReveal
            case .invalid, .deleteChat, .messagingRequest, .messagingRejection:
                return .text
            // TODO: return image item type when BE adds image message type
//            case .image:
//                return .image
            }
        }()

        self.id = message.id ?? UUID().uuidString
        self.text = message.text
        self.type = itemType
        self.isContact = message.isContact
        self.image = message.image?.dataFromBase64
        self.previewImage = message.image?.dataFromBase64(withCompression: Constants.imageCompressionQuality)
        self.imageView = Image(data: previewImage, placeholder: "")

        if type == .receiveIdentityReveal || type == .requestIdentityReveal,
           let gotResponse = message.chat?.publisher(for: \.gotRevealedResponse) {

            let isRevealed = message.isRevealed
            let hasResponse = message.hasRevealResponse

            type = Self.updateMessageType(isRevealed: isRevealed, hasResponse: hasResponse, type: type)

            gotResponse
                .filter { $0 }
                .map { [type] _ in Self.updateMessageType(isRevealed: isRevealed, hasResponse: hasResponse, type: type) }
                .assign(to: &$type)
        }
    }

    private static func updateMessageType(isRevealed: Bool, hasResponse: Bool, type: ItemType) -> ItemType {
        if hasResponse {
            return isRevealed ? .approveIdentityReveal : .rejectIdentityReveal
        } else {
            return type
        }
    }

    static func == (lhs: ChatConversationItem, rhs: ChatConversationItem) -> Bool {
        lhs.id == rhs.id
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
        case requestIdentityReveal
        case receiveIdentityReveal
        case approveIdentityReveal
        case rejectIdentityReveal
        case start
        case noContent
    }
}
