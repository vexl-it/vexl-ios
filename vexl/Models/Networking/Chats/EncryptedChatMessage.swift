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
    case revealRejected = "DISAPPROVE_REVEAL"
    case messagingRequest = "REQUEST_MESSAGING"
    case messagingApproval = "APPROVE_MESSAGING"
    case messagingRejection = "DISAPPROVE_MESSAGING"
    case deleteChat = "DELETE_CHAT"
    case invalid

    static var displayableMessages: [MessageType] {
        [.message, .revealRequest, .revealApproval, .revealRejected, .messagingApproval]
    }
}

struct EncryptedChatMessageList: Codable {
    let messages: [EncryptedChatMessage]
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
        Method used for decrypting the message string and returning it as a Dictionary
     
        - Parameters:
            - key: inbox key used to encrypt the message
     */
    func asJSON(with key: ECCKeys) -> [String: Any]? {
        // TODO: [vexl chat encryption] Uncomment this when enabling encryption on chat service
        guard // let decryptedMessage = try? message.ecc.decrypt(keys: key),
              let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return nil }
        return json as? [String: Any]
    }

    /**
        Method used for decrypting the message string and returning it as a String
     
        - Parameters:
            - key: inbox key used to encrypt the message
     */
    func asString(with key: ECCKeys) -> String? {
        // TODO: [vexl chat encryption] Uncomment this when enabling encryption on chat service
        guard //let decryptedMessage = try? message.ecc.decrypt(keys: key),
              let data = message.data(using: .utf8)  else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
