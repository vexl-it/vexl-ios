//
//  ParsedChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 9/06/22.
//

import Foundation

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

/// The struct used to contained the data that comes from the server using `EncryptedChatMessage`.
/// This will be stored in the databased and used for populating the Inbox and Chat user interfaces.
struct MessagePayload: Codable {

    /// Inbox that sent the message
    let contactInboxKey: String
    /// Inbox receiving the message
    let inboxKey: String
    /// Id used for internal purposes
    let id: String
    let text: String?
    let image: String?
    /// Message type send by the backend
    var messageTypeValue: String
    /// Message type for the content used internally in the device
    var contentTypeValue: String
    let time: TimeInterval
    /// Information of the sender, will contain data once the identity reveal is accepted.
    var user: ChatUser?

    var isFromContact = true

    var contentType: ContentType {
        ContentType(rawValue: contentTypeValue) ?? .none
    }

    var messageType: MessageType {
        MessageType(rawValue: messageTypeValue) ?? .invalid
    }

    var shouldBeStored: Bool {
        ![MessageType.revealRejected, .revealApproval, .deleteChat].contains(messageType)
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
            "time": time.milliseconds
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

extension MessagePayload {

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
              let time = json["time"] as? Int else {
                  return nil
              }

        let text = json["text"] as? String
        let image = json["image"] as? String

        self.contactInboxKey = chatMessage.senderPublicKey
        self.inboxKey = inboxPublicKey
        self.id = id
        self.text = text
        self.image = image
        self.contentTypeValue = contentType
        self.messageTypeValue = chatMessage.messageType
        self.time = TimeInterval(time) / 1_000
        self.user = ChatUser(name: json["username"] as? String,
                             image: json["userAvatar"] as? String)
    }

    /// Use this initializer to manually create a message,
    /// although it is recommended to use one of the static methods that will set the correct MessageType

    // swiftlint: disable function_default_parameter_at_end
    private init?(inboxPublicKey: String,
                  messageType: MessageType,
                  contentType: ContentType,
                  text: String,
                  image: String? = nil,
                  contactInboxKey: String,
                  user: ChatUser? = nil) {
        guard messageType != .invalid else { return nil }
        self.contactInboxKey = contactInboxKey
        self.id = UUID().uuidString
        self.text = text
        self.inboxKey = inboxPublicKey
        self.messageTypeValue = messageType.rawValue
        self.contentTypeValue = contentType.rawValue
        self.time = Date().timeIntervalSince1970
        self.image = image
        self.isFromContact = false
        self.user = user
    }
}

// MARK: - Helper methods for creating ParsedChatMessage of different types

extension MessagePayload {

    static func communicationRequest(inboxPublicKey: String, text: String, contactInboxKey: String) -> MessagePayload? {
        MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: .messagingRequest,
            contentType: .communicationRequest,
            text: text,
            contactInboxKey: contactInboxKey
        )
    }

    static func communicationConfirmation(isConfirmed: Bool, inboxPublicKey: String, contactInboxKey: String) -> MessagePayload? {
        MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: isConfirmed ? .messagingApproval : .messagingRejection,
            contentType: .communicationRequestResponse,
            text: L.chatMessageConversationRequestAccepted(),
            contactInboxKey: contactInboxKey
        )
    }

    static func createMessage(text: String, image: String?, inboxPublicKey: String?, contactInboxKey: String?) -> MessagePayload? {
        guard let inboxPublicKey = inboxPublicKey, let contactInboxKey = contactInboxKey else {
            return nil
        }

        let type: ContentType = image != nil ? .image : .text
        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: .message,
            contentType: type,
            text: text,
            image: image,
            contactInboxKey: contactInboxKey
        )
        return parsedMessage
    }

    static func createIdentityRequest(inboxPublicKey: String,
                                      contactInboxKey: String,
                                      username: String?,
                                      avatar: String?) -> MessagePayload? {
        let chatUser = ChatUser(name: username, image: avatar)
        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: .revealRequest,
            contentType: .anonymousRequest,
            text: "",
            image: nil,
            contactInboxKey: contactInboxKey,
            user: chatUser
        )
        return parsedMessage
    }

    static func createIdentityResponse(inboxPublicKey: String,
                                       contactInboxKey: String,
                                       isAccepted: Bool,
                                       username: String?,
                                       avatar: String?) -> MessagePayload? {
        let chatUser = ChatUser(name: username, image: avatar)
        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: isAccepted ? .revealApproval : .revealApproval,
            contentType: .anonymousRequestResponse,
            text: "",
            image: nil,
            contactInboxKey: contactInboxKey,
            user: chatUser
        )
        return parsedMessage
    }

    static func createDelete(inboxPublicKey: String, contactInboxKey: String) -> MessagePayload? {
        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: .deleteChat,
            contentType: .deleteChat,
            text: "",
            image: nil,
            contactInboxKey: contactInboxKey
        )
        return parsedMessage
    }
}
// MARK: - Enum and Structs

extension MessagePayload {

    struct ChatUser: Codable {
        let name: String
        let image: String?

        init?(name: String?, image: String?) {
            guard let name = name else { return nil }
            self.name = name
            self.image = image
        }
    }
}
