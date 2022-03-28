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
    case createUser(username: String, avatar: String?, security: SecurityHeader?)
    case confirmPhone(phoneNumber: String)
    case validateCode(id: Int, code: String, key: String)
    case validateChallenge(signature: String, key: String)
    case validateUsername(username: String, security: SecurityHeader?)
    case temporalGenerateKeys
    case temporalSignature(challenge: String, privateKey: String)

    var method: HTTPMethod {
        switch self {
        case .me, .temporalGenerateKeys:
            return .get
        case .createUser, .confirmPhone, .validateCode, .temporalSignature, .validateChallenge, .validateUsername:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        switch self {
        case let .createUser(_, _, security):
            return security?.header ?? []
        case let .validateUsername(_, security):
            return security?.header ?? []
        default:
            return []
        }
    }

    var path: String {
        switch self {
        case .me:
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
        case .temporalGenerateKeys:
            return "temp/key-pairs"
        case .temporalSignature:
            return "temp/signature"
        }
    }

    var parameters: Parameters {
        switch self {
        case .me, .temporalGenerateKeys:
            return [:]
        case let .temporalSignature(challenge, privateKey):
            return ["challenge": challenge,
                    "privateKey": privateKey]
        case let .createUser(username, avatar, _):
            guard let avatar = avatar else {
                return ["username": username]
            }
            return ["username": username, "avatar": avatar]
        case let .validateChallenge(signature, key):
            return ["userPublicKey": key,
                    "signature": signature]
        case let .confirmPhone(phoneNumber):
            return ["phoneNumber": phoneNumber]
        case let .validateUsername(username, _):
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
