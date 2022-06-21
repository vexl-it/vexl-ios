//
//  ParsedChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 9/06/22.
//

import Foundation

/// The struct used to contained the data that comes from the server using `EncryptedChatMessage`.
/// This will be stored in the databased and used for populating the Inbox and Chat user interfaces.
struct ParsedChatMessage: Codable {

    let senderKey: String
    let inboxKey: String
    /// Id used for internal purposes
    let id: String
    let text: String?
    let image: String?
    /// Message type send by the backend
    let messageTypeValue: String
    /// Message type for the content used internally in the device
    let contentTypeValue: String
    let time: TimeInterval
    /// Information of the sender, will contain data once the identity reveal is accepted.
    let user: ChatUser?

    var contentType: ContentType {
        guard text != nil && contentTypeValue == ContentType.text.rawValue else { return .none }
        guard image != nil && contentTypeValue == ContentType.image.rawValue else { return .none }
        return ContentType(rawValue: contentTypeValue) ?? .none
    }

    var messageType: MessageType {
        MessageType(rawValue: messageTypeValue) ?? .invalid
    }

    /**
        Initializer using an Encrypted message as parameter, also requires a the key used for encryption and the inboxPublicKey.
     
        - Paremeters:
            - chatMessage: an Encrypted message sent by the Backend
            - key: the key that will be used to decrypt the message
            - inboxPublicKey: the key of the inbox this message is part from
     */

    init?(chatMessage: EncryptedChatMessage, key: ECCKeys, inboxPublicKey: String) {
        guard let json = chatMessage.asJSON(with: key),
              let id = json["uuid"] as? String,
              let contentType = json["type"] as? String,
              let time = json["time"] as? TimeInterval else {
                  return nil
              }

        let text = json["text"] as? String
        let image = json["image"] as? String

        self.senderKey = chatMessage.senderPublicKey
        self.inboxKey = inboxPublicKey
        self.id = id
        self.text = text
        self.image = image
        self.messageTypeValue = chatMessage.messageType
        self.contentTypeValue = contentType
        self.time = time
        self.user = ChatUser(name: json["username"] as? String,
                             image: json["userAvatar"] as? String)
    }

    private init?(inboxPublicKey: String,
                  messageType: MessageType,
                  contentType: ContentType,
                  text: String,
                  image: String? = nil,
                  senderKey: String = "") {
        guard messageType != .invalid || messageType != .message else { return nil }
        self.senderKey = senderKey
        self.id = UUID().uuidString
        self.text = text
        self.inboxKey = inboxPublicKey
        self.messageTypeValue = messageType.rawValue
        self.contentTypeValue = contentType.rawValue
        self.time = Date().timeIntervalSince1970
        self.image = image
        self.user = nil
    }

    var asString: String? {
        var json: [String: Any] = [
            "uuid": id,
            "type": contentTypeValue,
            "time": time
        ]

        if let text = text {
            json["text"] = text
        }

        if let image = image {
            json["image"] = image
        }

        if let user = user {
            json["username"] = user.name
            json["userAvatar"] = user.image
        }

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Helper methods for transforming `ParsedChatMessage` to String

extension ParsedChatMessage {

    static func createMessagingRequest(inboxPublicKey: String, text: String, senderKey: String) -> String? {
        let parsedMessage = ParsedChatMessage(inboxPublicKey: inboxPublicKey,
                                              messageType: .messagingRequest,
                                              contentType: .communicationRequest,
                                              text: text,
                                              senderKey: senderKey)
        return parsedMessage?.asString
    }

    static func createMessage(text: String, image: String?, inboxKey: ECCKeys) -> String? {
        let type: ParsedChatMessage.ContentType = image != nil ? .image : .text
        let parsedMessage = ParsedChatMessage(inboxPublicKey: inboxKey.publicKey,
                                              messageType: .message,
                                              contentType: type,
                                              text: text,
                                              image: image)
        return parsedMessage?.asString
    }

    static func createIdentityRequest(inboxKey: ECCKeys) -> String? {
        let parsedMessage = ParsedChatMessage(inboxPublicKey: inboxKey.publicKey,
                                              messageType: .revealRequest,
                                              contentType: .anonymousRequest,
                                              text: "",
                                              image: nil)
        return parsedMessage?.asString
    }

    static func createDelete(inboxKey: ECCKeys) -> String? {
        let parsedMessage = ParsedChatMessage(inboxPublicKey: inboxKey.publicKey,
                                              messageType: .deleteChat,
                                              contentType: .deleteChat,
                                              text: "",
                                              image: nil)
        return parsedMessage?.asString
    }
}

extension ParsedChatMessage {

    enum ContentType: String {
        case text = "TEXT"
        case image = "IMAGE"
        case anonymousRequest = "ANON_REQUEST"
        case anonymousRequestResponse = "ANON_REQUEST_RESPONSE"
        case communicationRequest = "COMMUNICATION_REQUEST"
        case communicationRequestResponse = "COMMUNICATION_REQUEST_RESPONSE"
        case deleteChat = "DELETE_CHAT"
        case none
    }

    struct ChatUser: Codable {
        let name: String
        let image: String

        init?(name: String?, image: String?) {
            guard let name = name, let image = image else { return nil }
            self.name = name
            self.image = image
        }
    }
}
