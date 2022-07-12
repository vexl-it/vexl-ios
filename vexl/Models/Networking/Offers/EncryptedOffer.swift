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
    let userPublicKey: String
    var groupUuid: String
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

    var offerId: String = ""
    var createdAt: String = ""
    var modifiedAt: String = ""

    var activePriceState: String
    var activePriceValue: String
    var active: String

    var commonFriends: [String]

    // TODO: - add real values for commonFriends, active, activePriceValu, activePriceState when components are implemented

    var asJson: [String: Any] {
        [
            "userPublicKey": userPublicKey,
            "groupUuid": groupUuid,
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
            "offerType": offerType,
            "activePriceState": activePriceState,
            "activePriceValue": activePriceValue,
            "active": active,
            "commonFriends": commonFriends
        ]
    }
}
