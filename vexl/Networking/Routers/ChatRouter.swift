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
    case createInbox(offerPublicKey: String, pushToken: String)
    case request(inboxPublicKey: String, message: String)
    case requestConfirmation(confirmed: Bool, message: String, inboxPublicKey: String,
                             requesterPublicKey: String, signature: String)
    case requestChallenge(publicKey: String)
    case pullChat(publicKey: String, signature: String)
    case deleteChat(publicKey: String)
    case deleteChatMessages(publicKey: String)

    var method: HTTPMethod {
        switch self {
        case .createInbox, .request, .requestChallenge, .requestConfirmation:
            return .post
        case .pullChat:
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
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.chatBaseURLString
    }
}
