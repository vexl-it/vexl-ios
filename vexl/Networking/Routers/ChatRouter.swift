//
//  ChatRouter.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Alamofire

enum ChatRouter: ApiRouter {
    case request(inboxPublicKey: String, message: String)

    var method: HTTPMethod {
        switch self {
        case .request:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .request:
            return "inboxes/allowance/request"
        }
    }

    var parameters: Parameters {
        switch self {
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
