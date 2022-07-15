//
//  OfferPayload.swift
//  vexl
//
//  Created by Diego Espinoza on 30/04/22.
//

import Foundation

struct OfferPayloadList: Codable {
    let offerPrivateList: [OfferPayload]

    init(list: [OfferPayload]) {
        self.offerPrivateList = list
    }
}

struct OfferPayload: Codable {
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
    let currency: String

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
            "currency": currency,
            "activePriceState": activePriceState,
            "activePriceValue": activePriceValue,
            "active": active,
            "commonFriends": commonFriends
        ]
    }

    init(offer: ManagedOffer, encryptionPublicKey: String, commonFriends: [String]) throws {
        let minAmount = try offer.minAmount.ecc.encrypt(publicKey: encryptionPublicKey)
        let maxAmount = try offer.maxAmount.ecc.encrypt(publicKey: encryptionPublicKey)
        let feeAmount = try offer.feeAmount.ecc.encrypt(publicKey: encryptionPublicKey)
        let activePriceValue = try offer.activePriceValue.ecc.encrypt(publicKey: encryptionPublicKey)
        let active = try offer.active.ecc.encrypt(publicKey: encryptionPublicKey)
        let commonFriends = try commonFriends.map({ try $0.ecc.encrypt(publicKey: encryptionPublicKey) })
        guard
            let offerPublicKey = try offer.inbox?.keyPair?.publicKey?.ecc.encrypt(publicKey: encryptionPublicKey),
            let description = try offer.offerDescription?.ecc.encrypt(publicKey: encryptionPublicKey),
            let feeState = try offer.feeStateRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let locationState = try offer.locationStateRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let paymentMethods: [String] = try offer.paymentMethodRawTypes?.map({ try $0.ecc.encrypt(publicKey: encryptionPublicKey) }),
            let btcNetwork: [String] = try offer.btcNetworkRawTypes?.map({ try $0.ecc.encrypt(publicKey: encryptionPublicKey) }),
            let friendLevel = try offer.friendDegreeRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let offerType = try offer.offerTypeRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let activePriceState = try offer.activePriceStateRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let groupUuid = try offer.groupUuidRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let currency = try offer.currencyRawType?.ecc.encrypt(publicKey: encryptionPublicKey)
        else {
            throw EncryptionError.dataEncryption
        }

        // TODO: - convert locations to JSON and then to string and set real Location

        let fakeLocation = OfferLocation(latitude: 14.418_540,
                                         longitude: 50.073_658,
                                         radius: 1)
        let locationString = fakeLocation.asString ?? ""
        let encryptedString = try? locationString.ecc.encrypt(publicKey: encryptionPublicKey)

        self.userPublicKey = encryptionPublicKey
        self.groupUuid = groupUuid
        self.location = [encryptedString ?? ""]
        self.offerPublicKey = offerPublicKey
        self.offerDescription = description
        self.amountTopLimit = maxAmount
        self.amountBottomLimit = minAmount
        self.feeState = feeState
        self.feeAmount = feeAmount
        self.locationState = locationState
        self.paymentMethod = paymentMethods
        self.btcNetwork = btcNetwork
        self.friendLevel = friendLevel
        self.offerType = offerType
        self.currency = currency
        self.activePriceState = activePriceState
        self.activePriceValue = activePriceValue
        self.active = active
        self.commonFriends = commonFriends
    }
}
