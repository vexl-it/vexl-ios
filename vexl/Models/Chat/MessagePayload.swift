//
//  ParsedChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 9/06/22.
//

import Foundation

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
    let time: TimeInterval
    /// Information of the sender, will contain data once the identity reveal is accepted.
    var user: ChatUser?

    var isFromContact = true

    var messageType: MessageType {
        MessageType(rawValue: messageTypeValue) ?? .invalid
    }

    var shouldBeStored: Bool {
        ![MessageType.revealRejected, .revealApproval, .deleteChat].contains(messageType)
    }

    var avatar: Data? {
        nil
    }

    var username: String? {
        user?.name ?? L.generalAnonymous()
    }

    var asString: String? {
        var json: [String: Any] = [
            "uuid": id,
            "time": time.milliseconds
        ]

        if let text = text {
            json["text"] = text
        }

        if let image = image {
            json["image"] = image
        }

        if let user = user {
            var jsonUser = [
                "name": user.name,
                "image": user.imageURL
            ]

            if let imageData = user.imageData {
                jsonUser["imageBase64"] = imageData
            }

            json["deanonymizedUser"] = jsonUser
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
              let time = json["time"] as? Int else {
                  return nil
              }

        let text = json["text"] as? String
        let image = json["image"] as? String
        let jsonUser = json["deanonymizedUser"] as? [String: Any]
        let userName = jsonUser?["name"] as? String
        let userImage = jsonUser?["image"] as? String
        let userImageData = jsonUser?["imageBase64"] as? String

        self.contactInboxKey = chatMessage.senderPublicKey
        self.inboxKey = inboxPublicKey
        self.id = id
        self.text = text
        self.image = image
        self.messageTypeValue = chatMessage.messageType
        self.time = TimeInterval(time) / 1_000
        self.user = ChatUser(name: userName, imageURL: userImage, imageData: userImageData)
    }

    /// Use this initializer to manually create a message,
    /// although it is recommended to use one of the static methods that will set the correct MessageType

    // swiftlint: disable function_default_parameter_at_end
    private init?(inboxPublicKey: String,
                  messageType: MessageType,
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
            text: text,
            contactInboxKey: contactInboxKey
        )
    }

    static func communicationConfirmation(isConfirmed: Bool, inboxPublicKey: String, contactInboxKey: String) -> MessagePayload? {
        MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: isConfirmed ? .messagingApproval : .messagingRejection,
            text: L.chatMessageConversationRequestAccepted(),
            contactInboxKey: contactInboxKey
        )
    }

    static func createMessage(text: String, image: String?, inboxPublicKey: String?, contactInboxKey: String?) -> MessagePayload? {
        guard let inboxPublicKey = inboxPublicKey, let contactInboxKey = contactInboxKey else {
            return nil
        }

        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: .message,
            text: text,
            image: image,
            contactInboxKey: contactInboxKey
        )
        return parsedMessage
    }

    static func createIdentityRequest(inboxPublicKey: String,
                                      contactInboxKey: String,
                                      username: String?,
                                      avatar: String?,
                                      avatarData: String?) -> MessagePayload? {
        let chatUser = ChatUser(name: username, imageURL: avatar, imageData: avatarData)
        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: .revealRequest,
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
                                       avatar: String?,
                                       avatarData: String?) -> MessagePayload? {
        let chatUser = ChatUser(name: username, imageURL: avatar, imageData: avatarData)
        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: isAccepted ? .revealApproval : .revealRejected,
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
            text: "",
            image: nil,
            contactInboxKey: contactInboxKey
        )
        return parsedMessage
    }

    static func createBlock(inboxPublicKey: String, contactInboxKey: String) -> MessagePayload? {
        let parsedMessage = MessagePayload(
            inboxPublicKey: inboxPublicKey,
            messageType: .blockChat,
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
        let imageURL: String?
        let imageData: String?

        init?(name: String?, imageURL: String?, imageData: String?) {
            guard let name = name else { return nil }
            self.name = name
            self.imageURL = imageURL
            self.imageData = imageData
        }
    }
}
