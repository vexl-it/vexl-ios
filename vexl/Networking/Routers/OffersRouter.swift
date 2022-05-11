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
    case getOffers(pageLimit: Int?)
    case getUserOffers(offerIds: [String])

    var method: HTTPMethod {
        switch self {
        case .getOffers, .getUserOffers:
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
        case .createOffer, .getUserOffers:
            return "offers"
        }
    }

    var parameters: Parameters {
        switch self {
        case let .getOffers(pageLimit):
            guard let pageLimit = pageLimit else {
                return [:]
            }
            return ["limit": pageLimit]
        case let .getUserOffers(offerIds):
            return ["offerIds": offerIds.joined(separator: ",")]
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
