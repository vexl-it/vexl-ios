//
//  ChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 3/06/22.
//

import Foundation

enum MessageType: String {
    case message = "MESSAGE"
    case revealRequest = "REQUEST_REVEAL"
    case revealApproval = "APPROVE_REVEAL"
    case messagingRequest = "REQUEST_MESSAGING"
    case messagingApproval = "APPROVE_MESSAGING"
    case messagingRejection = "DISAPPROVE_MESSAGING"
    case deleteChat = "DELETE_CHAT"
    case invalid
}

struct EncryptedChatMessage: Codable {

    let senderPublicKey: String
    let message: String
    let messageType: String

    var type: MessageType {
        MessageType(rawValue: messageType) ?? .invalid
    }

    init?(chatMessage: ParsedChatMessage, type: MessageType) {
        guard type != .invalid else { return nil }
        guard let value = chatMessage.asString else { return nil }
        self.senderPublicKey = chatMessage.key
        self.message = value
        self.messageType = type.rawValue
    }

    func asJSON(with key: ECCKeys) -> [String: Any]? {
        guard let decryptedMessage = try? message.ecc.decrypt(keys: key),
              let data = decryptedMessage.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return nil }
        return json as? [String: Any]
    }

    func asString(with key: ECCKeys) -> String? {
        guard let decryptedMessage = try? message.ecc.decrypt(keys: key),
              let data = decryptedMessage.data(using: .utf8)  else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
