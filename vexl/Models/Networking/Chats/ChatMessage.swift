//
//  ChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 3/06/22.
//

import Foundation

struct ChatMessage: Codable {
    let senderPublicKey: String
    let message: String

    init?(chatMessage: ParsedChatMessage) {
        guard let value = chatMessage.asString else { return nil }
        self.senderPublicKey = chatMessage.key
        self.message = value
    }

    var asJSON: [String: Any]? {
        guard let data = message.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else { return nil }
        return json as? [String: Any]
    }
}

struct ParsedChatMessage: Codable {

    enum MessageType: String {
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

    let key: String
    let id: String
    let text: String?
    let image: String?
    let type: String
    let from: String
    let time: TimeInterval
    let user: ChatUser?

    var messageType: MessageType {
        guard text != nil && type == MessageType.text.rawValue else { return .invalid }
        guard image != nil && type == MessageType.image.rawValue else { return .invalid }
        return MessageType(rawValue: type) ?? .invalid
    }

    init?(chatMessage: ChatMessage) {
        guard let json = chatMessage.asJSON else { return nil }
        guard let id = json["id"] as? String,
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

    var asString: String? {
        var json: [String: Any] = [
            "id": id,
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
