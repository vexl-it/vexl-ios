//
//  EncryptedOffer.swift
//  vexl
//
//  Created by Diego Espinoza on 30/04/22.
//

import Foundation

struct EncryptedOfferList: Codable {
    let offerPrivateList: [EncryptedOffer]

    init(list: [EncryptedOffer]) {
        self.offerPrivateList = list
    }
}

struct EncryptedOffer: Codable {
    let offerId: String
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
    let createdAt: String
    let modifiedAt: String

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
        self.offerId = ""
        self.createdAt = ""
        self.modifiedAt = ""
    }

    var asJson: [String: Any] {
        let fakeLocation = OfferLocation(latitude: 14.418540,
                                         longitude: 50.073658,
                                         radius: 1)
        let locationString = fakeLocation.asString ?? ""
        let encryptedString = try? locationString.ecc.encrypt(publicKey: userPublicKey) ?? ""
        return [
            "userPublicKey": userPublicKey,
            "location": [encryptedString],
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
