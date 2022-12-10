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
}

struct ChatMessageEnvelope {
    let receiverPublicKey: String
    var message: String
    let messageType: MessageType
}

struct BatchMessageEnvelope {
    let senderPublicKey: String
    let messages: [ChatMessageEnvelope]
}

struct BatchChallengeEnvelope: Decodable {
    let challenges: [PublicKeyChallenge]

    struct PublicKeyChallenge: Decodable {
        let publicKey: String
        let challenge: String
    }
}
