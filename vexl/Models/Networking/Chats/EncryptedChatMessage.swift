//
//  ChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 3/06/22.
//

import Foundation

/// Message types that are returned by the backend
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

/// Message that comes from the backend and that contains the payload encrypted as a string.
struct EncryptedChatMessage: Codable {

    /// Public key of the user sending the message
    let senderPublicKey: String
    /// The message payload as a string and encrypted using the inbox public key
    let message: String
    /// The message type, see `MessageType`
    let messageType: String

    var type: MessageType {
        MessageType(rawValue: messageType) ?? .invalid
    }

    /**
        Initializer for creating an encrypted message using the `ParsedChatMessage` as the base
     
        - Parameters:
            - chatMessage: the message content inside a `ParsedChatMessage`
            - type: the message type accepted by the backend
     */
    init?(chatMessage: ParsedChatMessage, type: MessageType) {
        guard type != .invalid else { return nil }
        guard let value = chatMessage.asString else { return nil }
        self.senderPublicKey = chatMessage.senderKey
        self.message = value
        self.messageType = type.rawValue
    }

    /**
        Method used for decrypting the message string and returning it as a Dictionary
     
        - Parameters:
            - key: inbox key used to encrypt the message
     */
    func asJSON(with key: ECCKeys) -> [String: Any]? {
        guard let decryptedMessage = try? message.ecc.decrypt(keys: key),
              let data = decryptedMessage.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return nil }
        return json as? [String: Any]
    }

    /**
        Method used for decrypting the message string and returning it as a String
     
        - Parameters:
            - key: inbox key used to encrypt the message
     */
    func asString(with key: ECCKeys) -> String? {
        guard let decryptedMessage = try? message.ecc.decrypt(keys: key),
              let data = decryptedMessage.data(using: .utf8)  else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
