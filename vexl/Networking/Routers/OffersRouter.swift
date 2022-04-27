//
//  OffersRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 27/04/22.
//

import Foundation
import Alamofire

enum OffersRouter: ApiRouter {
    case createOffer

    var method: HTTPMethod {
        switch self {
        case .createOffer:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        return securityHeader
    }

    var path: String {
        switch self {
        case .createOffer:
            return "offers"
        }
    }

    var parameters: Parameters {
        switch self {
        case .createOffer:
            return [:]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.offersBaseURLString
    }
}

