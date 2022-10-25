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
    case confirmPhone(phoneNumber: String)
    case validateCode(id: Int, code: String, key: String)
    case validateChallenge(signature: String, key: String)
    case facebookSignature(id: String)
    case bitcoin
    case bitcoinChart(currency: Currency, option: TimelineOption)

    var method: HTTPMethod {
        switch self {
        case .facebookSignature, .bitcoin, .bitcoinChart:
            return .get
        case .confirmPhone, .validateCode, .validateChallenge:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        switch self {
        case .facebookSignature, .bitcoin, .bitcoinChart:
            return securityHeader
        default:
            return []
        }
    }

    var path: String {
        switch self {
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

    var version: Constants.API.Version? { .v1 }

    var parameters: Parameters {
        switch self {
        case .facebookSignature, .bitcoin:
            return [:]
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
            return ["duration": option.duration, "currency": currency.rawValue]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.userBaseURLString
    }
}
