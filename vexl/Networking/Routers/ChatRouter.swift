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
    case requestChallenge(publicKey: String)
    case pullChat(publicKey: String, signature: String)
    case deleteChat(publicKey: String)

    var method: HTTPMethod {
        switch self {
        case .createInbox, .request, .requestChallenge:
            return .post
        case .pullChat:
            return .put
        case .deleteChat:
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
            return "inboxes/allowance/request"
        case .requestChallenge:
            return "challenges"
        case .pullChat:
            return "inboxes/messages"
        case let .deleteChat(publicKey):
            return "inboxes/\(publicKey)"
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
        case .deleteChat:
            return [:]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.chatBaseURLString
    }
}
