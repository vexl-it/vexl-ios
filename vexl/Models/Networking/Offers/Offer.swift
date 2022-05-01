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

struct Offer: Codable {

    let offerId: String

    let minAmount: Int
    let maxAmount: Int
    let description: String
    let feeState: String
    let feeAmount: Double
    let locationState: String
    let paymentMethods: [String]
    let btcNetwork: [String]
    let friendLevel: String
    let type: String

    var createdAt: String
    var modifiedAt: String

    init(minAmount: Int,
         maxAmount: Int,
         description: String,
         feeState: String,
         feeAmount: Double,
         locationState: String,
         paymentMethods: [String],
         btcNetwork: [String],
         friendLevel: String,
         type: OfferType) {
        self.minAmount = minAmount
        self.maxAmount = maxAmount
        self.description = description
        self.feeState = feeState
        self.feeAmount = feeAmount
        self.locationState = locationState
        self.paymentMethods = paymentMethods
        self.btcNetwork = btcNetwork
        self.friendLevel = friendLevel
        self.type = type.rawValue
        self.offerId = ""
        self.createdAt = ""
        self.modifiedAt = ""
    }

    var minAmountString: String {
        "\(minAmount)"
    }

    var maxAmountString: String {
        "\(maxAmount)"
    }

    var feeAmountString: String {
        "\(feeAmount)"
    }

    var offerTypeValue: OfferType {
        OfferType(rawValue: type) ?? .sell
    }

    var createdDate: Date? {
        Formatters.dateApiFormatter.date(from: createdAt)
    }

    var modifiedDate: Date? {
        Formatters.dateApiFormatter.date(from: modifiedAt)
    }
}
