//
//  Offer.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import Foundation

enum OfferType: String {
    case sell = "SELL"
    case buy = "BUY"
}

struct Offer {
    let minAmount: Int
    let maxAmount: Int
    let description: String
    let feeState: OfferFeeOption
    let feeAmount: Double
    let locationState: OfferTradeLocationOption
    let paymentMethods: [OfferPaymentMethodOption]
    let btcNetwork: [OfferAdvancedBTCOption]
    let friendLevel: OfferAdvancedFriendDegreeOption
    let type: OfferType

    var offerId: String = ""
    var createdAt: String = ""
    var modifiedAt: String = ""

    // TODO: - Implement initializer that receives EncryptedOffer -> Creates readable Offer

    var minAmountString: String {
        "\(minAmount)"
    }

    var maxAmountString: String {
        "\(maxAmount)"
    }

    var feeAmountString: String {
        "\(feeAmount)"
    }

    var feeStateString: String {
        feeState.rawValue
    }

    var locationStateString: String {
        locationState.rawValue
    }

    var paymentMethodsList: [String] {
        paymentMethods.map(\.rawValue)
    }

    var btcNetworkList: [String] {
        btcNetwork.map(\.rawValue)
    }

    var friendLevelString: String {
        friendLevel.rawValue
    }

    var offerTypeString: String {
        type.rawValue
    }

    var createdDate: Date? {
        Formatters.dateApiFormatter.date(from: createdAt)
    }

    var modifiedDate: Date? {
        Formatters.dateApiFormatter.date(from: modifiedAt)
    }
}
