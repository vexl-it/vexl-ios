//
//  ChatRouter.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Alamofire

enum ChatRouter: ApiRouter {
    case createInbox(offerPublicKey: String, pushToken: String)
    case request(inboxPublicKey: String, message: String)
    case blockInbox(publicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool)
    case sendMessage(senderPublicKey: String, receiverPublicKey: String, message: String)

    var method: HTTPMethod {
        switch self {
        case .createInbox, .request, .sendMessage:
            return .post
        case .blockInbox:
            return .put
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .createInbox:
            return "inboxes"
        case .request:
            return "inboxes/allowance/request"
        case .blockInbox:
            return "inboxes/block"
        case .sendMessage:
            return "inboxes/messages"
        }
    }

    var parameters: Parameters {
        switch self {
        case let .createInbox(offerPublicKey, pushToken):
            return [
                "publicKey": offerPublicKey,
                "token": pushToken
            ]
        case let .request(inboxPublicKey, message):
            return [
                "publicKey": inboxPublicKey,
                "message": message
            ]
        case let .blockInbox(publicKey, publicKeyToBlock, signature, isBlocked):
            return [
                "publicKey": publicKey,
                "publicKeyToBlock": publicKeyToBlock,
                "signature": signature,
                "block": isBlocked
            ]
        case let .sendMessage(senderPublicKey, receiverPublicKey, message):
            return [
                "senderPublicKey": senderPublicKey,
                "receiverPublicKey": receiverPublicKey,
                "messageType": "MESSAGE",
                "message": message
            ]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.chatBaseURLString
    }
}
