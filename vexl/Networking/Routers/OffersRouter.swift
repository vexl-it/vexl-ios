//
//  OffersRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 27/04/22.
//

import Foundation
import Alamofire

enum OffersRouter: ApiRouter {
    case createOffer(offer: [EncryptedOffer], expiration: TimeInterval)
    case getOffers(pageLimit: Int?)
    case getUserOffers(offerIds: [String])
    case deleteOffers(offerIds: [String])
    case updateOffer(offer: [EncryptedOffer], offerId: String)

    var method: HTTPMethod {
        switch self {
        case .getOffers, .getUserOffers:
            return .get
        case .createOffer:
            return .post
        case .deleteOffers:
            return .delete
        case .updateOffer:
            return .put
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .getOffers:
            return "offers/me"
        case .createOffer, .getUserOffers, .deleteOffers, .updateOffer:
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
        case let .getUserOffers(offerIds), let .deleteOffers(offerIds):
            return ["offerIds": offerIds.joined(separator: ",")]
        case let .createOffer(offer, expiration):
            let offers = offer.map { $0.asJson }
            return ["offerPrivateList": offers,
                    "expiration": expiration]
        case let .updateOffer(offer, offerId):
            let offers = offer.map { $0.asJson }
            return ["offerId": offerId,
                    "offerPrivateCreateList": offers]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.offersBaseURLString
    }
}
