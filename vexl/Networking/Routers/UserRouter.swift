//
//  UserRouter.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import Alamofire

enum UserRouter: ApiRouter {
    case me
    case createUser(username: String, avatar: String?, imageExtension: String)
    case deleteUser
    case confirmPhone(phoneNumber: String)
    case validateCode(id: Int, code: String, key: String)
    case validateChallenge(signature: String, key: String)
    case facebookSignature(id: String)
    case validateUsername(username: String)
    case bitcoin

    var method: HTTPMethod {
        switch self {
        case .me, .facebookSignature, .bitcoin:
            return .get
        case .createUser, .confirmPhone, .validateCode, .validateChallenge, .validateUsername:
            return .post
        case .deleteUser:
            return .delete
        }
    }

    var additionalHeaders: [Header] {
        switch self {
        case .createUser, .validateUsername, .facebookSignature, .bitcoin, .deleteUser:
            return securityHeader
        default:
            return []
        }
    }

    var path: String {
        switch self {
        case .me, .deleteUser:
            return "user/me"
        case .createUser:
            return "user"
        case .confirmPhone:
            return "user/confirmation/phone"
        case .validateCode:
            return "user/confirmation/code"
        case .validateUsername:
            return "user/username/availability"
        case .validateChallenge:
            return "user/confirmation/challenge"
        case let .facebookSignature(id):
            return "user/signature/\(id)"
        case .bitcoin:
            return "cryptocurrencies/bitcoin/"
        }
    }

    var parameters: Parameters {
        switch self {
        case .me, .facebookSignature, .bitcoin, .deleteUser:
            return [:]
        case let .createUser(username, avatar, imageExtension):
            guard let avatar = avatar else {
                return ["username": username]
            }
            return ["username": username,
                    "avatar": ["extension": imageExtension, "data": avatar]]
        case let .validateChallenge(signature, key):
            return ["userPublicKey": key,
                    "signature": signature]
        case let .confirmPhone(phoneNumber):
            return ["phoneNumber": phoneNumber]
        case let .validateUsername(username):
            return ["username": username]
        case let .validateCode(id, code, key):
            return ["id": id,
                    "code": code,
                    "userPublicKey": key]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.userBaseURLString
    }
}
