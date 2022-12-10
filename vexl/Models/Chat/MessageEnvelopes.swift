//
//  MessageEnvelopes.swift
//  vexl
//
//  Created by Adam Salih on 10.12.2022.
//

import Foundation

struct MessageEnvelope {
    let senderPublicKey: String
    let receiverPublicKey: String
    let message: String
    let messageType: MessageType

    var asJson: [String: Any] {
        [
            "senderPublicKey": senderPublicKey,
            "receiverPublicKey": receiverPublicKey,
            "messageType": messageType.rawValue,
            "message": message
        ]
    }
}

struct ChatMessageEnvelope {
    let receiverPublicKey: String
    var message: String
    let messageType: MessageType

    init?(chat: ManagedChat) {
        guard
            let inboxKeys = chat.inbox?.keyPair?.keys,
            let receiverPublicKey = chat.receiverKeyPair?.publicKey,
            let payload = MessagePayload.createDelete(inboxPublicKey: inboxKeys.publicKey, contactInboxKey: receiverPublicKey),
            let payloadJson = payload.asString else {
            return nil
        }
        self.message = payloadJson
        self.messageType = payload.messageType
        self.receiverPublicKey = receiverPublicKey
    }

    init(receiverPublicKey: String, message: String, messageType: MessageType) {
        self.receiverPublicKey = receiverPublicKey
        self.message = message
        self.messageType = messageType
    }
}

struct BatchMessageEnvelope {
    let senderPublicKey: String
    let messages: [ChatMessageEnvelope]

    var asJson: [String: Any] {
        [
            "senderPublicKey": senderPublicKey,
            "messages": messages.map { message in
                [
                    "receiverPublicKey": message.receiverPublicKey,
                    "messageType": message.messageType.rawValue,
                    "message": message.message
                ]
            }
        ]
    }

    init?(inbox: ManagedInbox) {
        guard let inboxKeys = inbox.keyPair?.keys else {
            return nil
        }
        let chats = inbox.chats?.allObjects as? [ManagedChat] ?? []
        self.messages = chats.compactMap(ChatMessageEnvelope.init)
        self.senderPublicKey = inboxKeys.publicKey
    }

    init(senderPublicKey: String, messages: [ChatMessageEnvelope]) {
        self.senderPublicKey = senderPublicKey
        self.messages = messages
    }
}

struct BatchChallengeEnvelope: Decodable {
    let challenges: [PublicKeyChallenge]

    struct PublicKeyChallenge: Decodable {
        let publicKey: String
        let challenge: String
    }
}
