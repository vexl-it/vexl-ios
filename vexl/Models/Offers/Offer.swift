//
//  Offer.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import Foundation

struct Offer {
    var offerId: String = ""
    var groupUuid: GroupUUID = .none
    var offerPublicKey: String = ""
    var offerPrivateKey: String?
    var userPublicKey: String = ""
    var createdAt: String = ""
    var modifiedAt: String = ""
    var currency: Currency = .usd

    let minAmount: Double
    let maxAmount: Double
    let description: String
    let feeState: OfferFeeOption
    let feeAmount: Double
    let locationState: OfferTradeLocationOption
    let paymentMethods: [OfferPaymentMethodOption]
    let btcNetwork: [OfferAdvancedBTCOption]
    let friendLevel: OfferAdvancedFriendDegreeOption
    let type: OfferType
    let source: OfferSource

    var priceTrigger: OfferTrigger = .none
    var priceTriggerValue: Double = 0.0
    var isActive: Bool = true
    var commonFriends: [String] = []

    init(minAmount: Int,
         maxAmount: Int,
         description: String,
         feeState: OfferFeeOption,
         feeAmount: Double,
         locationState: OfferTradeLocationOption,
         paymentMethods: [OfferPaymentMethodOption],
         btcNetwork: [OfferAdvancedBTCOption],
         friendLevel: OfferAdvancedFriendDegreeOption,
         type: OfferType,
         priceTriggerState: OfferTrigger,
         priceTriggerValue: Double,
         isActive: Bool,
         source: OfferSource) {
        self.minAmount = Double(minAmount)
        self.maxAmount = Double(maxAmount)
        self.description = description
        self.feeState = feeState
        self.feeAmount = feeAmount
        self.locationState = locationState
        self.paymentMethods = paymentMethods
        self.btcNetwork = btcNetwork
        self.friendLevel = friendLevel
        self.type = type
        self.priceTrigger = priceTriggerState
        self.priceTriggerValue = priceTriggerValue
        self.isActive = isActive
        self.source = source
    }

    init?(storedOffer: StoredOffer) {
        guard let feeState = OfferFeeOption(rawValue: storedOffer.feeState),
              let locationState = OfferTradeLocationOption(rawValue: storedOffer.locationState),
              let friendLevel = OfferAdvancedFriendDegreeOption(rawValue: storedOffer.friendLevel),
              let type = OfferType(rawValue: storedOffer.type),
              let source = OfferSource(rawValue: storedOffer.source) else {
                  return nil
              }

        self.offerId = storedOffer.id
        self.minAmount = storedOffer.minAmount
        self.maxAmount = storedOffer.maxAmount
        self.description = storedOffer.description
        self.feeState = feeState
        self.feeAmount = storedOffer.feeAmount
        self.locationState = locationState
        self.paymentMethods = Self.generatePaymentMethods(storedOffer.paymentMethods)
        self.btcNetwork = Self.generateBTCNetwork(storedOffer.btcNetwork)
        self.friendLevel = friendLevel
        self.type = type
        self.offerPrivateKey = storedOffer.privateKey
        self.offerPublicKey = storedOffer.publicKey
        self.source = source
        self.priceTrigger = OfferTrigger(rawValue: storedOffer.priceTrigger) ?? .none
        self.priceTriggerValue = storedOffer.priceTriggerValue
        self.isActive = storedOffer.isActive
    }

    init?(encryptedOffer: EncryptedOffer, keys: ECCKeys, source: OfferSource) throws {
        do {
            let minAmountString = try encryptedOffer.amountBottomLimit.ecc.decrypt(keys: keys)
            let maxAmountString = try encryptedOffer.amountTopLimit.ecc.decrypt(keys: keys)
            let feeAmountString = try encryptedOffer.feeAmount.ecc.decrypt(keys: keys)
            let currencyString = try encryptedOffer.currency.ecc.decrypt(keys: keys)

            let feeStateString = try encryptedOffer.feeState.ecc.decrypt(keys: keys)
            let locationStateString = try encryptedOffer.locationState.ecc.decrypt(keys: keys)
            let friendLevelString = try encryptedOffer.friendLevel.ecc.decrypt(keys: keys)
            let offerTypeString = try encryptedOffer.offerType.ecc.decrypt(keys: keys)
            let offerPublicKey = try encryptedOffer.offerPublicKey.ecc.decrypt(keys: keys)

            let isActiveString = try encryptedOffer.active.ecc.decrypt(keys: keys)
            let activePriceStateString = try encryptedOffer.activePriceState.ecc.decrypt(keys: keys)
            let activePriceValueString = try encryptedOffer.activePriceValue.ecc.decrypt(keys: keys)

            let paymentMethods = Self.getPaymentMethods(encryptedOffer.paymentMethod, withKeys: keys)
            let btcNetworks = Self.getBTCNetwork(encryptedOffer.btcNetwork, withKeys: keys)

            guard let minAmount = Double(minAmountString),
                  let maxAmount = Double(maxAmountString),
                  let feeAmount = Double(feeAmountString),
                  let activePriceValue = Double(activePriceValueString),
                  let isActive = Bool(isActiveString),
                  let currency = Currency(rawValue: currencyString),
                  let feeState = OfferFeeOption(rawValue: feeStateString),
                  let locationState = OfferTradeLocationOption(rawValue: locationStateString),
                  let friendLevel = OfferAdvancedFriendDegreeOption(rawValue: friendLevelString),
                  let activePriceState = OfferTrigger(rawValue: activePriceStateString),
                  let offerType = OfferType(rawValue: offerTypeString) else {
                      return nil
                  }

            guard btcNetworks.count == encryptedOffer.btcNetwork.count
                    && paymentMethods.count == encryptedOffer.paymentMethod.count else {
                return nil
            }

            self.offerId = encryptedOffer.offerId
            self.groupUuid = GroupUUID(rawValue: encryptedOffer.groupUuid)
            self.createdAt = encryptedOffer.createdAt
            self.modifiedAt = encryptedOffer.modifiedAt
            self.userPublicKey = encryptedOffer.userPublicKey
            self.source = source
            self.currency = currency

            self.minAmount = minAmount
            self.maxAmount = maxAmount
            self.feeAmount = feeAmount
            self.offerPublicKey = offerPublicKey
            self.description = try encryptedOffer.offerDescription.ecc.decrypt(keys: keys)

            self.feeState = feeState
            self.locationState = locationState
            self.friendLevel = friendLevel
            self.type = offerType

            self.isActive = isActive
            self.priceTrigger = activePriceState
            self.priceTriggerValue = activePriceValue

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

    var createdDate: Date {
        Formatters.dateApiFormatter.date(from: createdAt) ?? Date()
    }

    var modifiedDate: Date? {
        Formatters.dateApiFormatter.date(from: modifiedAt)
    }

    var keysWithId: OfferKeys {
        OfferKeys(id: offerId, publicKey: offerPublicKey, privateKey: offerPrivateKey)
    }

    // MARK: - Helper static methods for creating list of offers

    static func createOffers(from encryptedOffers: [EncryptedOffer], withKey key: ECCKeys, source: OfferSource) -> [Offer] {
        var offers: [Offer] = []
        for encryptedOffer in encryptedOffers {
            if let offer = try? Offer(encryptedOffer: encryptedOffer, keys: key, source: source) {
                offers.append(offer)
            }
        }
        return offers
    }

    // MARK: - Helper methods for array generation

    private static func getPaymentMethods(_ paymentMethods: [String], withKeys keys: ECCKeys) -> [OfferPaymentMethodOption] {
        let decryptedPaymentMethods = Self.decryptPaymentMethods(paymentMethods, keys: keys)
        return Self.generatePaymentMethods(decryptedPaymentMethods)
    }

    private static func getBTCNetwork(_ btcNetwork: [String], withKeys keys: ECCKeys) -> [OfferAdvancedBTCOption] {
        let decryptedBTCNetwork = Self.decryptBTCNetwork(btcNetwork, keys: keys)
        return Self.generateBTCNetwork(decryptedBTCNetwork)
    }

    private static func generatePaymentMethods(_ paymentMethodList: [String]) -> [OfferPaymentMethodOption] {
        var paymentMethods: [OfferPaymentMethodOption] = []

        paymentMethodList.forEach { method in
            if let paymentMethod = OfferPaymentMethodOption(rawValue: method) {
                paymentMethods.append(paymentMethod)
            }
        }

        return paymentMethods
    }

    private static func generateBTCNetwork(_ btcNetworkList: [String]) -> [OfferAdvancedBTCOption] {
        var btcNetworks: [OfferAdvancedBTCOption] = []

        btcNetworkList.forEach { network in
            if let btcNetwork = OfferAdvancedBTCOption(rawValue: network) {
                btcNetworks.append(btcNetwork)
            }
        }

        return btcNetworks
    }

    private static func decryptPaymentMethods(_ paymentMethod: [String],
                                              keys: ECCKeys) -> [String] {
        var paymentMethodList: [String] = []

        paymentMethod.forEach { method in
            if let decryptedMethod = try? method.ecc.decrypt(keys: keys) {
                paymentMethodList.append(decryptedMethod)
            }
        }

        return paymentMethodList
    }

    private static func decryptBTCNetwork(_ btcNetwork: [String],
                                          keys: ECCKeys) -> [String] {
        var btcNetworkList: [String] = []

        btcNetwork.forEach { network in
            if let decryptedNetwork = try? network.ecc.decrypt(keys: keys) {
                btcNetworkList.append(decryptedNetwork)
            }
        }

        return btcNetworkList
    }
}

extension Offer: Equatable {
    static func == (lhs: Offer, rhs: Offer) -> Bool {
        lhs.offerId == rhs.offerId
    }
}

extension Offer {
    static var stub: Offer = Offer(
        minAmount: 100,
        maxAmount: 300,
        description: "Offer stub",
        feeState: .withoutFee,
        feeAmount: 0,
        locationState: .online,
        paymentMethods: [.bank],
        btcNetwork: [.lightning],
        friendLevel: .firstDegree,
        type: .buy,
        priceTriggerState: .above,
        priceTriggerValue: 20_000,
        isActive: true,
        source: .fetched
    )

    static var stub2: Offer = Offer(
        minAmount: 1_000,
        maxAmount: 3_000,
        description: "Offer stub 2",
        feeState: .withoutFee,
        feeAmount: 0,
        locationState: .online,
        paymentMethods: [.revolut],
        btcNetwork: [.lightning],
        friendLevel: .firstDegree,
        type: .buy,
        priceTriggerState: .below,
        priceTriggerValue: 20_000,
        isActive: false,
        source: .created
    )
}
