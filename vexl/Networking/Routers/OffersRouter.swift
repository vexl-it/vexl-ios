//
//  OffersRouter.swift
//  vexl
//
//  Created by Diego Espinoza on 27/04/22.
//

import Foundation
import Alamofire

enum OffersRouter: ApiRouter {

    case createOffer(offerPayload: OfferRequestPayload)
    case getOffers(pageLimit: Int?)
    case getUserOffers(offerIds: [String])
    case getNewOffers(pageLimit: Int?, lastSyncDate: Date)
    case createNewPrivateParts(adminID: String, offerPrivateParts: [OfferPayloadPrivateWrapperEncrypted])
    case getDeletedOffers(knownOfferIds: [String])
    case report(offerID: String)

    case deleteOffers(adminIDs: [String])
    case deleteOfferPrivateParts(adminIDs: [String], publicKeys: [String])
    case updateOffer(offerPayload: OfferRequestPayload, adminID: String)

    var method: HTTPMethod {
        switch self {
        case .getOffers, .getUserOffers, .getNewOffers:
            return .get
        case .createOffer, .createNewPrivateParts, .getDeletedOffers, .report:
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
        case .report:
            return "offers/report"
        case .createOffer, .getUserOffers, .deleteOffers, .updateOffer:
            return "offers"
        case .createNewPrivateParts, .deleteOfferPrivateParts:
            return "offers/private-part"
        case .getDeletedOffers:
            return "offers/not-exist"
        }
    }
    
    var version: Constants.API.Version? {
        switch self {
        case .createOffer, .getOffers, .getUserOffers, .getNewOffers, .createNewPrivateParts, .updateOffer:
            return .v2
        case .getDeletedOffers, .report, .deleteOffers, .deleteOfferPrivateParts:
            return .v1
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
        case let .getUserOffers(offerIds):
            return ["offerIds": offerIds.joined(separator: ",")]
        case let .report(offerID):
            return ["offerId": offerID]
        case let .deleteOffers(adminIDs):
            return ["adminIds": adminIDs.joined(separator: ",")]
        case let .createOffer(offerPayload):
            return offerPayload.asJson
        case let .updateOffer(offer, adminId):
            var offerPayload = offer.asJson
            offerPayload["adminId"] = adminId
            return offerPayload
        case let .createNewPrivateParts(adminId, offers):
            return [
                "adminId": adminId,
                "privateParts": offers.map(\.asJson)
            ]
        case let .deleteOfferPrivateParts(adminIds, publicKeys):
            return [
                "adminIds": adminIds,
                "publicKeys": publicKeys
            ]
        case let .getDeletedOffers(knownOfferIds):
            return ["offerIds": knownOfferIds]
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
