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
    case createNewPrivateParts(adminID: String, offerPayloads: [OfferPayload])
    case getDeletedOffers(knownOfferIds: [String])

    case deleteOffers(adminIDs: [String])
    case deleteOfferPrivateParts(adminIDs: [String], publicKeys: [String])
    case updateOffer(offer: [OfferPayload], adminID: String)

    var method: HTTPMethod {
        switch self {
        case .getOffers, .getUserOffers, .getNewOffers:
            return .get
        case .createOffer, .createNewPrivateParts, .getDeletedOffers:
            return .post
        case .deleteOffers, .deleteOfferPrivateParts:
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
        case .getNewOffers:
            return "offers/me/modified"
        case .getOffers:
            return "offers/me"
        case .createOffer, .getUserOffers, .deleteOffers, .updateOffer:
            return "offers"
        case .createNewPrivateParts, .deleteOfferPrivateParts:
            return "offers/private-part"
        case .getDeletedOffers:
            return "offers/not-exist"
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
        case let .updateOffer(offer, adminId):
            let offers = offer.map { $0.asJson }
            return ["adminId": adminId,
                    "offerPrivateCreateList": offers]
        case let .createNewPrivateParts(adminId, offers):
            let offers = offers.map { $0.asJson }
            return [
                "adminId": adminId,
                "privateParts": offers
            ]
        case let .deleteOfferPrivateParts(adminIds, publicKeys):
            return [
                "adminIds": adminIds,
                "publicKeys": publicKeys
            ]
        case let .getDeletedOffers(knownOfferIds):
            return ["adminIds": knownOfferIds]
        }
    }

    var authType: AuthType {
        .bearer
    }

    var url: String {
        Constants.API.offersBaseURLString
    }

    var useURLEncoding: Bool {
        switch self {
        case .deleteOffers:
            return true
        default:
            return false
        }
    }
}
