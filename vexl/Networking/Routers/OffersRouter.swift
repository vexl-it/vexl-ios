//
//  OffersRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 27/04/22.
//

import Foundation
import Alamofire

enum OffersRouter: ApiRouter {
    case createOffer(offerPayloads: [OfferPayload], expiration: TimeInterval)
    case getOffers(pageLimit: Int?)
    case getUserOffers(offerIds: [String])
    case getNewOffers(pageLimit: Int?, lastSyncDate: Date)

    case deleteOffers(offerIds: [String])

    var method: HTTPMethod {
        switch self {
        case .getOffers, .getUserOffers, .getNewOffers:
            return .get
        case .createOffer:
            return .post
        case .deleteOffers:
            return .delete
        }
    }

    var additionalHeaders: [Header] {
        securityHeader
    }

    var path: String {
        switch self {
        case .getNewOffers:
            return "offers/me/modified"
        case .getOffers:
            return "offers/me"
        case .createOffer, .getUserOffers, .deleteOffers:
            return "offers"
        }
    }

    var parameters: Parameters {
        switch self {
        case let .getNewOffers(pageLimit, lastSyncDate):
            guard let pageLimit = pageLimit else {
                return [:]
            }
            return [
                "limit": pageLimit,
                "modifiedAt": Formatters.apiUTCFormatter.string(from: lastSyncDate)
            ]
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
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.offersBaseURLString
    }
}
