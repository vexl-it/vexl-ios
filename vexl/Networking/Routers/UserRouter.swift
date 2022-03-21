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
    case createUser(username: String, avatar: String)
    case confirmPhone(phoneNumber: String)
    case validateCode(id: Int, code: String, key: String)
    case temporalGenerateKeys

    var method: HTTPMethod {
        switch self {
        case .me, .temporalGenerateKeys:
            return .get
        case .createUser, .confirmPhone, .validateCode:
            return .post
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
        case .temporalGenerateKeys:
            return "temp/key-pairs"
        }
    }

    var parameters: Parameters {
        switch self {
        case .me, .temporalGenerateKeys:
            return [:]
        case let .createUser(username, avatar):
            return ["username": username,
                    "avatar": avatar]
        case let .confirmPhone(phoneNumber):
            return ["phoneNumber": phoneNumber]
        case let .validateCode(id, code, key):
            return ["id": id,
                    "code": code,
                    "userPublicKey": key]
        }
    }

    var authType: AuthType {
        .bearer
    }
}
