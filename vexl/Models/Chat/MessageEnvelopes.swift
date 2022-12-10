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
}

struct BatchChallengeEnvelope: Decodable {
    let challenges: [PublicKeyChallenge]

    struct PublicKeyChallenge: Decodable {
        let publicKey: String
        let challenge: String
    }
}
