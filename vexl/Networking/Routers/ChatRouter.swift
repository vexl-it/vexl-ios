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

    var method: HTTPMethod {
        switch self {
        case .createInbox, .request:
            return .post
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
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.chatBaseURLString
    }
}
