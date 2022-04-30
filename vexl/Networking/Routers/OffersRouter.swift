//
//  OffersRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 27/04/22.
//

import Foundation
import Alamofire

enum OffersRouter: ApiRouter {
    case createOffer(offer: [EncryptedOffer])

    var method: HTTPMethod {
        switch self {
        case .createOffer:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .createOffer:
            return "offers"
        }
    }

    var parameters: Parameters {
        switch self {
        case let .createOffer(offer):
            return ["offerPrivateList": offer]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.offersBaseURLString
    }
}
