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

struct ParsedChatMessage: Codable {

    enum InputType: String {
        case text = "TEXT"
        case image = "IMAGE"
        case anonymousRequest = "ANON_REQUEST"
        case anonymousRequestResponse = "ANON_REQUEST_RESPONSE"
        case communicationRequest = "COMMUNICATION_REQUEST"
        case communicationRequestResponse = "COMMUNICATION_REQUEST_RESPONSE"
        case deleteChat = "DELETE_CHAT"
        case invalid
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

    let key: String //senderKey
    let id: String
    let text: String?
    let image: String?
    let type: String
    let from: String
    let time: TimeInterval
    let user: ChatUser?

    var messageType: InputType {
        guard text != nil && type == InputType.text.rawValue else { return .invalid }
        guard image != nil && type == InputType.image.rawValue else { return .invalid }
        return InputType(rawValue: type) ?? .invalid
    }

    init?(chatMessage: EncryptedChatMessage, key: ECCKeys) {
        guard let json = chatMessage.asJSON(with: key),
              let id = json["uuid"] as? String,
              let type = json["type"] as? String,
              let from = json["from"] as? String,
              let time = json["time"] as? TimeInterval else {
                  return nil
              }

        let text = json["text"] as? String
        let image = json["image"] as? String

        self.key = chatMessage.senderPublicKey
        self.id = id
        self.text = text
        self.image = image
        self.type = type
        self.from = from
        self.time = time
        self.user = ChatUser(name: json["username"] as? String,
                             image: json["userAvatar"] as? String)
    }

    init?(inboxPublicKey: String, type: MessageType, text: String, senderKey: String) {
        guard type != .invalid || type != .message else { return nil }
        self.key = senderKey
        self.id = UUID().uuidString
        self.text = text
        self.from = inboxPublicKey
        self.type = type.rawValue
        self.time = Date().timeIntervalSince1970
        self.image = nil
        self.user = nil
    }

    var asString: String? {
        var json: [String: Any] = [
            "uuid": id,
            "type": type,
            "from": from,
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
