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
    case updateUser(username: String, avatar: String?, imageExtension: String)
    case deleteUser
    case confirmPhone(phoneNumber: String)
    case validateCode(id: Int, code: String, key: String)
    case validateChallenge(signature: String, key: String)
    case facebookSignature(id: String)
    case bitcoin
    case bitcoinChart(currency: Currency, option: TimelineOption)

    var method: HTTPMethod {
        switch self {
        case .me, .facebookSignature, .bitcoin, .bitcoinChart:
            return .get
        case .createUser, .confirmPhone, .validateCode, .validateChallenge:
            return .post
        case .deleteUser:
            return .delete
        case .updateUser:
            return .put
        }
    }

    var additionalHeaders: [Header] {
        switch self {
        case .createUser, .facebookSignature, .bitcoin, .deleteUser, .bitcoinChart, .updateUser:
            return securityHeader
        default:
            return []
        }
    }

    var path: String {
        switch self {
        case .me, .deleteUser, .updateUser:
            return "user/me"
        case .createUser:
            return "user"
        case .confirmPhone:
            return "user/confirmation/phone"
        case .validateCode:
            return "user/confirmation/code"
        case .validateChallenge:
            return "user/confirmation/challenge"
        case let .facebookSignature(id):
            return "user/signature/\(id)"
        case .bitcoin:
            return "cryptocurrencies/bitcoin/"
        case .bitcoinChart:
            return "cryptocurrencies/bitcoin/market_chart"
        }
    }

    var parameters: Parameters {
        switch self {
        case .me, .facebookSignature, .bitcoin, .deleteUser:
            return [:]
        case let .createUser(username, avatar, imageExtension),
             let .updateUser(username, avatar, imageExtension):
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
        case let .validateCode(id, code, key):
            return ["id": id,
                    "code": code,
                    "userPublicKey": key]
        case let .bitcoinChart(currency, option):
            let range = option.chartEndpointRange
            return ["from": range.from, "to": range.to, "currency": currency.rawValue]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.userBaseURLString
    }
}
