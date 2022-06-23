//
//  ParsedChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 9/06/22.
//

import Foundation

struct ParsedChatMessage: Codable {

    let senderKey: String
    let inboxKey: String
    let id: String
    let text: String?
    let image: String?
    let messageTypeValue: String // type send by the server
    let contentTypeValue: String // type for the content used locally by devices
    let time: TimeInterval
    let user: ChatUser?

    var contentType: ContentType {
        guard text != nil && contentTypeValue == ContentType.text.rawValue else { return .none }
        guard image != nil && contentTypeValue == ContentType.image.rawValue else { return .none }
        return ContentType(rawValue: contentTypeValue) ?? .none
    }

    var messageType: MessageType {
        MessageType(rawValue: messageTypeValue) ?? .invalid
    }

    var previewText: String {
        switch contentType {
        case .text, .communicationRequestResponse:
            return text ?? ""
        case .image:
            return L.chatMessageConversationImage()
        default:
            return ""
        }
    }

    var avatar: Data? {
        nil
    }

    var username: String? {
        user?.name ?? Constants.randomName
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

// MARK: - Initializers and helpers

extension ParsedChatMessage {

    /// Use this initializer for parsing the encrypted message from the Backend

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
        self.contentTypeValue = contentType
        self.messageTypeValue = chatMessage.messageType
        self.time = time
        self.user = ChatUser(name: json["username"] as? String,
                             image: json["userAvatar"] as? String)
    }

    /// Use this initializer to manually create a message,
    /// although it is recommended to use one of the static methods that will set the correct MessageType

    init?(inboxPublicKey: String, messageType: MessageType, contentType: ContentType, text: String, senderKey: String) {
        guard messageType != .invalid || messageType != .message else { return nil }
        self.senderKey = senderKey
        self.id = UUID().uuidString
        self.text = text
        self.inboxKey = inboxPublicKey
        self.messageTypeValue = messageType.rawValue
        self.contentTypeValue = contentType.rawValue
        self.time = Date().timeIntervalSince1970
        self.image = nil
        self.user = nil
    }

    static func createRequestConfirmation(isConfirmed: Bool, inboxPublicKey: String, senderKey: String) -> ParsedChatMessage? {
        ParsedChatMessage(inboxPublicKey: inboxPublicKey,
                          messageType: isConfirmed ? .messagingApproval : .messagingRejection,
                          contentType: .communicationRequestResponse,
                          text: L.chatMessageConversationRequestAccepted(),
                          senderKey: senderKey)
    }

    static func createMessagingRequest(inboxPublicKey: String, senderKey: String, text: String) -> ParsedChatMessage? {
        ParsedChatMessage(inboxPublicKey: inboxPublicKey,
                          messageType: .messagingRequest,
                          contentType: .communicationRequest,
                          text: text,
                          senderKey: senderKey)
    }
}

// MARK: - Enum and Structs

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
