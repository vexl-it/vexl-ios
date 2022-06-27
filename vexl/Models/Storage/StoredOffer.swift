//
//  StoredOffer.swift
//  vexl
//
//  Created by Diego Espinoza on 27/06/22.
//

import Foundation

// TODO: - delete this when the CoreData Offer is created

struct StoredOffer: Codable {
    
    struct Keys {
        let id: String
        let publicKey: String
        let privateKey: String?

        var keys: ECCKeys {
            ECCKeys(pubKey: publicKey, privKey: privateKey)
        }
    }

    let id: String
    let privateKey: String?
    let publicKey: String

    var minAmount: Int
    var maxAmount: Int
    var description: String
    var feeState: String
    var feeAmount: Double
    var locationState: String
    var btcNetwork: [String]
    var friendLevel: String
    var type: String

    var offerType: OfferType? {
        OfferType(rawValue: type)
    }

    var keys: ECCKeys {
        ECCKeys(pubKey: publicKey, privKey: privateKey)
    }
    
    init(offer: Offer, id: String, keys: ECCKeys) {
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
        self.friendLevel = offer.friendLevelString
        self.type = offer.offerTypeString
    }
    
    func getIdWithKeys() -> Keys {
        Keys(id: id, publicKey: publicKey, privateKey: privateKey)
    }
}
