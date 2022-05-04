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
    var offerPublicKey: String = ""
    var createdAt: String = ""
    var modifiedAt: String = ""

    init(minAmount: Int,
         maxAmount: Int,
         description: String,
         feeState: OfferFeeOption,
         feeAmount: Double,
         locationState: OfferTradeLocationOption,
         paymentMethods: [OfferPaymentMethodOption],
         btcNetwork: [OfferAdvancedBTCOption],
         friendLevel: OfferAdvancedFriendDegreeOption,
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
        self.type = type
        self.offerId = ""
        self.createdAt = ""
        self.modifiedAt = ""
        self.offerPublicKey = ""
    }

    // swiftlint: disable function_body_length
    init?(encryptedOffer: EncryptedOffer, keys: ECCKeys) throws {
        do {
            let minAmountString = try encryptedOffer.amountBottomLimit.ecc.decrypt(keys: keys)
            let maxAmountString = try encryptedOffer.amountTopLimit.ecc.decrypt(keys: keys)
            let feeAmountString = try encryptedOffer.feeAmount.ecc.decrypt(keys: keys)

            let feeStateString = try encryptedOffer.feeState.ecc.decrypt(keys: keys)
            let locationStateString = try encryptedOffer.locationState.ecc.decrypt(keys: keys)
            let friendLevelString = try encryptedOffer.friendLevel.ecc.decrypt(keys: keys)
            let offerTypeString = try encryptedOffer.offerType.ecc.decrypt(keys: keys)
            let offerPublicKey = try encryptedOffer.offerPublicKey.ecc.decrypt(keys: keys)

            var paymentMethodList: [String] = []
            var btcNetworkList: [String] = []

            let numberOfPaymentMethods = encryptedOffer.paymentMethod.count
            let numberOfBTCNetwork = encryptedOffer.btcNetwork.count

            encryptedOffer.paymentMethod.forEach { method in
                if let decryptedMethod = try? method.ecc.decrypt(keys: keys) {
                    paymentMethodList.append(decryptedMethod)
                }
            }

            encryptedOffer.btcNetwork.forEach { network in
                if let decryptedNetwork = try? network.ecc.decrypt(keys: keys) {
                    btcNetworkList.append(decryptedNetwork)
                }
            }

            guard let minAmount = Int(minAmountString),
                  let maxAmount = Int(maxAmountString),
                  let feeAmount = Double(feeAmountString) else {
                      return nil
                  }

            guard let feeState = OfferFeeOption(rawValue: feeStateString),
                  let locationState = OfferTradeLocationOption(rawValue: locationStateString),
                  let friendLevel = OfferAdvancedFriendDegreeOption(rawValue: friendLevelString),
                  let offerType = OfferType(rawValue: offerTypeString) else {
                      return nil
                  }

            var paymentMethods: [OfferPaymentMethodOption] = []
            var btcNetworks: [OfferAdvancedBTCOption] = []

            paymentMethodList.forEach { method in
                if let paymentMethod = OfferPaymentMethodOption(rawValue: method) {
                    paymentMethods.append(paymentMethod)
                }
            }

            btcNetworkList.forEach { network in
                if let btcNetwork = OfferAdvancedBTCOption(rawValue: network) {
                    btcNetworks.append(btcNetwork)
                }
            }

            guard btcNetworkList.count == numberOfBTCNetwork
                    && paymentMethods.count == numberOfPaymentMethods else {
                return nil
            }

            self.offerId = encryptedOffer.offerId
            self.createdAt = encryptedOffer.createdAt
            self.modifiedAt = encryptedOffer.modifiedAt

            self.minAmount = minAmount
            self.maxAmount = maxAmount
            self.feeAmount = feeAmount
            self.offerPublicKey = offerPublicKey
            self.description = try encryptedOffer.offerDescription.ecc.decrypt(keys: keys)

            self.feeState = feeState
            self.locationState = locationState
            self.friendLevel = friendLevel
            self.type = offerType

            self.paymentMethods = paymentMethods
            self.btcNetwork = btcNetworks
        } catch {
            throw EncryptionError.offerDecryption
        }
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
