//
//  ChatRouter.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Alamofire

// swiftlint: disable enum_case_associated_values_count
enum ChatRouter: ApiRouter {
    case createInbox(publicKey: String, pushToken: String?)
    case request(inboxPublicKey: String, message: String)
    case requestConfirmation(confirmed: Bool, message: String, inboxPublicKey: String,
                             requesterPublicKey: String, signature: String)
    case requestChallenge(publicKey: String)
    case pullChat(publicKey: String, signature: String)
    case deleteChat(publicKey: String)
    case blockInbox(publicKey: String, publicKeyToBlock: String, signature: String, isBlocked: Bool)
    case sendMessage(senderPublicKey: String, receiverPublicKey: String, message: String, messageType: MessageType)
    case deleteChatMessages(publicKey: String)

    var method: HTTPMethod {
        switch self {
        case .createInbox, .request, .requestChallenge, .requestConfirmation, .sendMessage:
            return .post
        case .pullChat, .blockInbox:
            return .put
        case .deleteChat, .deleteChatMessages:
            return .delete
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
            return "inboxes/approval/request"
        case .requestChallenge:
            return "challenges"
        case .pullChat:
            return "inboxes/messages"
        case .deleteChat:
            return "inboxes"
        case .deleteChatMessages:
            return "inboxes/messages"
        case .requestConfirmation:
            return "inboxes/approval/confirm"
        case .blockInbox:
            return "inboxes/block"
        case .sendMessage:
            return "inboxes/messages"
        }
    }

    var parameters: Parameters {
        switch self {
        case let .createInbox(publicKey, pushToken):
            guard let pushToken = pushToken else {
                return ["publicKey": publicKey]
            }
            return [
                "publicKey": publicKey,
                "token": pushToken
            ]
        case let .request(inboxPublicKey, message):
            return [
                "publicKey": inboxPublicKey,
                "message": message
            ]
        case let .requestChallenge(publicKey):
            return [
                "publicKey": publicKey
            ]
        case let .pullChat(publicKey, signature):
            return [
                "publicKey": publicKey,
                "signature": signature
            ]
        case let .requestConfirmation(confirmed, message, inboxPublicKey, requesterPublicKey, signature):
            return [
                "publicKey": inboxPublicKey,
                "publicKeyToConfirm": requesterPublicKey,
                "signature": signature,
                "message": message,
                "approve": confirmed
            ]
        case let .deleteChat(publicKey):
            return ["publicKey": publicKey]
        case let .deleteChatMessages(publicKey):
            return ["publicKey": publicKey]
        case let .blockInbox(publicKey, publicKeyToBlock, signature, isBlocked):
            return [
                "publicKey": publicKey,
                "publicKeyToBlock": publicKeyToBlock,
                "signature": signature,
                "block": isBlocked
            ]
        case let .sendMessage(senderPublicKey, receiverPublicKey, message, messageType):
            return [
                "senderPublicKey": senderPublicKey,
                "receiverPublicKey": receiverPublicKey,
                "messageType": messageType.rawValue,
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
