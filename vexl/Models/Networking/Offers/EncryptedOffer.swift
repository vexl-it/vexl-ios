//
//  EncryptedOffer.swift
//  vexl
//
//  Created by Diego Espinoza on 30/04/22.
//

import Foundation

struct CreatedOffer: Codable {
    let id: String
    let createdAt: Date
    let modifiedAt: Date
}

struct EncryptedOfferList: Codable {
    let offerPrivateList: [EncryptedOffer]

    init(list: [EncryptedOffer]) {
        self.offerPrivateList = list
    }
}

struct EncryptedOffer: Codable {
    let userPublicKey: String
    let location: [String]
    let offerPublicKey: String
    let offerDescription: String
    let amountTopLimit: String
    let amountBottomLimit: String
    let feeState: String
    let feeAmount: String
    let locationState: String
    let paymentMethod: [String]
    let btcNetwork: [String]
    let friendLevel: String
    let offerType: String

    init(userPublicKey: String,
         location: [String],
         offerPublicKey: String,
         offerDescription: String,
         amountTopLimit: String,
         amountBottomLimit: String,
         feeState: String,
         feeAmount: String,
         locationState: String,
         paymentMethod: [String],
         btcNetwork: [String],
         friendLevel: String,
         offerType: String) {
        self.userPublicKey = userPublicKey
        self.location = location
        self.offerPublicKey = offerPublicKey
        self.offerDescription = offerDescription
        self.amountTopLimit = amountTopLimit
        self.amountBottomLimit = amountBottomLimit
        self.feeState = feeState
        self.feeAmount = feeAmount
        self.locationState = locationState
        self.paymentMethod = paymentMethod
        self.btcNetwork = btcNetwork
        self.friendLevel = friendLevel
        self.offerType = offerType
    }

    var asJson: [String: Any] {
        [
            "userPublicKey": userPublicKey,
            "location": location,
            "offerPublicKey": offerPublicKey,
            "offerDescription": offerDescription,
            "amountTopLimit": amountTopLimit,
            "amountBottomLimit": amountBottomLimit,
            "feeState": feeState,
            "feeAmount": feeAmount,
            "locationState": locationState,
            "paymentMethod": paymentMethod,
            "btcNetwork": btcNetwork,
            "friendLevel": friendLevel,
            "offerType": offerType
        ]
    }
}
