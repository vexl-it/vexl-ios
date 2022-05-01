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
    case getOffers

    var method: HTTPMethod {
        switch self {
        case .getOffers:
            return .get
        case .createOffer:
            return .post
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .getOffers:
            return "offers/me"
        case .createOffer:
            return "offers"
        }
    }

    var parameters: Parameters {
        switch self {
        case .getOffers:
            return [:]
        case let .createOffer(offer):
            let offers = offer.map { $0.asJson }
            return ["offerPrivateList": offers]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.offersBaseURLString
    }
}
