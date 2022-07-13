//
//  StoredOffer.swift
//  vexl
//
//  Created by Diego Espinoza on 27/06/22.
//

import Foundation

// TODO: - delete this when the CoreData Offer is created

struct StoredOffer: Codable {

    let id: String
    let privateKey: String?
    let publicKey: String

    var minAmount: Double
    var maxAmount: Double
    var description: String
    var feeState: String
    var feeAmount: Double
    var locationState: String
    var paymentMethods: [String]
    var btcNetwork: [String]
    var friendLevel: String
    // TODO: - add new stuff
    var type: String
    var source: String

    var offerType: OfferType? {
        OfferType(rawValue: type)
    }

    var keys: ECCKeys {
        ECCKeys(pubKey: publicKey, privKey: privateKey)
    }

    init(offer: Offer, id: String, keys: ECCKeys, source: OfferSource) {
        self.id = id
        self.publicKey = keys.publicKey
        self.privateKey = keys.privateKey

        self.minAmount = offer.minAmount
        self.maxAmount = offer.maxAmount
        self.description = offer.description
        self.feeState = offer.feeStateString
        self.feeAmount = offer.feeAmount
        self.locationState = offer.locationStateString
        self.btcNetwork = offer.btcNetworkList
        self.paymentMethods = offer.paymentMethodsList
        self.friendLevel = offer.friendLevelString
        self.type = offer.offerTypeString
        self.source = source.rawValue
    }
}
