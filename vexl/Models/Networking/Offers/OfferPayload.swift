//
//  OfferPayload.swift
//  vexl
//
//  Created by Diego Espinoza on 30/04/22.
//

import Foundation
import CoreData

// swiftlint:disable unnecessary_parenthesis

struct OfferPayloadList: Codable {
    let offerPrivateList: [OfferPayload]

    init(list: [OfferPayload]) {
        self.offerPrivateList = list
    }
}

struct OfferIdList: Codable {
    var offerIds: [String]
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

    var offerId: String?
    var adminId: String?
    var createdAt: String = ""
    var modifiedAt: String = ""

    var activePriceState: String
    var activePriceValue: String
    var activePriceCurrency: String
    var active: String

    var commonFriends: [String]

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
            "activePriceCurrency": activePriceCurrency,
            "active": active,
            "commonFriends": commonFriends
        ]
    }

    init(offer: ManagedOffer, encryptionPublicKey: String, commonFriends: [String]) throws {
        let minAmount = try offer.minAmount.ecc.encrypt(publicKey: encryptionPublicKey)
        let maxAmount = try offer.maxAmount.ecc.encrypt(publicKey: encryptionPublicKey)
        let feeAmount = try offer.feeAmount.ecc.encrypt(publicKey: encryptionPublicKey)
        let activePriceValue = try offer.activePriceValue.ecc.encrypt(publicKey: encryptionPublicKey)
        let activePriceCurrency = try Currency.usd.rawValue.ecc.encrypt(publicKey: encryptionPublicKey)
        let active = try offer.active.ecc.encrypt(publicKey: encryptionPublicKey)
        let commonFriends = try commonFriends.map({ try $0.ecc.encrypt(publicKey: encryptionPublicKey) })
        let paymentMethods = try offer.paymentMethods.map(\.rawValue).map({ try $0.ecc.encrypt(publicKey: encryptionPublicKey) })
        let btcNetwork = try offer.btcNetworks.map(\.rawValue).map({ try $0.ecc.encrypt(publicKey: encryptionPublicKey) })
        guard
            let offerPublicKey = try offer.inbox?.keyPair?.publicKey?.ecc.encrypt(publicKey: encryptionPublicKey),
            let description = try offer.offerDescription?.ecc.encrypt(publicKey: encryptionPublicKey),
            let feeState = try offer.feeStateRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let locationState = try offer.locationStateRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let friendLevel = try offer.friendDegreeRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let offerType = try offer.offerTypeRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let activePriceState = try offer.activePriceStateRawType?.ecc.encrypt(publicKey: encryptionPublicKey),
            let groupUuid = try offer.groupUuid?.rawValue.ecc.encrypt(publicKey: encryptionPublicKey),
            let currency = try offer.currencyRawType?.ecc.encrypt(publicKey: encryptionPublicKey)
        else {
            throw EncryptionError.dataEncryption
        }

        if let managedLocations = offer.locations?.allObjects as? [ManagedOfferLocation] {
            let locations = managedLocations.compactMap(OfferLocation.init)
            let locationStrings = locations.compactMap { $0.asString }
            let encryptedLocationStrings = locationStrings.compactMap {
                try? $0.ecc.encrypt(publicKey: encryptionPublicKey)
            }
            self.location = encryptedLocationStrings
        } else {
            self.location = []
        }

        self.userPublicKey = encryptionPublicKey
        self.groupUuid = groupUuid
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
        self.activePriceCurrency = activePriceCurrency
        self.active = active
        self.commonFriends = commonFriends
    }

    // swiftlint:disable:next function_body_length
    @discardableResult
    func decrypt(context: NSManagedObjectContext,
                 userInbox: ManagedInbox,
                 into offer: ManagedOffer) -> ManagedOffer? {
        guard let keys = userInbox.keyPair?.keys else {
            return nil
        }
        do {
            let minAmountString = try amountBottomLimit.ecc.decrypt(keys: keys)
            let maxAmountString = try amountTopLimit.ecc.decrypt(keys: keys)
            let feeAmountString = try feeAmount.ecc.decrypt(keys: keys)
            let currencyString = try currency.ecc.decrypt(keys: keys)

            let feeStateString = try feeState.ecc.decrypt(keys: keys)
            let locationStateString = try locationState.ecc.decrypt(keys: keys)
            let friendLevelString = try friendLevel.ecc.decrypt(keys: keys)
            let offerTypeString = try offerType.ecc.decrypt(keys: keys)
            let offerPublicKey = try offerPublicKey.ecc.decrypt(keys: keys)

            let isActiveString = try active.ecc.decrypt(keys: keys)
            let activePriceStateString = try activePriceState.ecc.decrypt(keys: keys)
            let activePriceValueString = try activePriceValue.ecc.decrypt(keys: keys)

            let paymentMethods = Self.getPaymentMethods(paymentMethod, withKeys: keys)
            let btcNetworks = Self.getBTCNetwork(btcNetwork, withKeys: keys)
            let commonFirends = try commonFriends.compactMap { hash -> String? in
                if !hash.isEmpty {
                    return try hash.ecc.decrypt(keys: keys)
                }
                return nil
            }

            let groupUuid = try self.groupUuid.ecc.decrypt(keys: keys)

            guard let minAmount = Double(minAmountString),
                  let maxAmount = Double(maxAmountString),
                  let feeAmount = Double(feeAmountString),
                  let activePriceValue = Double(activePriceValueString),
                  let isActive = Bool(isActiveString),
                  let currency = Currency(rawValue: currencyString),
                  let feeState = OfferFeeOption(rawValue: feeStateString),
                  let locationState = OfferTradeLocationOption(rawValue: locationStateString),
                  let friendLevel = OfferFriendDegree(rawValue: friendLevelString),
                  let activePriceState = OfferTrigger(rawValue: activePriceStateString),
                  let offerType = OfferType(rawValue: offerTypeString) else {
                      return nil
                  }

            guard btcNetworks.count == btcNetwork.count
                    && paymentMethods.count == paymentMethod.count else {
                return nil
            }

            offer.offerID = offerId
            offer.adminID = adminId
            offer.createdAt = Formatters.dateApiFormatter.date(from: createdAt)
            offer.modifiedAt = modifiedAt
            offer.currency = currency
            offer.minAmount = minAmount
            offer.maxAmount = maxAmount
            offer.feeAmount = feeAmount
            offer.offerDescription = try offerDescription.ecc.decrypt(keys: keys)
            offer.feeState = feeState
            offer.locationState = locationState
            offer.friendLevel = friendLevel
            offer.type = offerType
            offer.active = isActive
            offer.activePriceState = activePriceState
            offer.activePriceValue = activePriceValue
            offer.paymentMethods = paymentMethods
            offer.btcNetworks = btcNetworks
            offer.commonFriends = commonFirends

            let locationStrings = try location.map { try $0.ecc.decrypt(keys: keys) }
            let offerLocations = locationStrings.compactMap(OfferLocation.init)
            let managedLocations = offerLocations.map { offerLocation -> ManagedOfferLocation in
                let managedLocation = ManagedOfferLocation(context: context)
                managedLocation.lat = offerLocation.latitude
                managedLocation.lon = offerLocation.longitude
                managedLocation.city = offerLocation.city
                return managedLocation
            }

            offer.locations = NSSet(array: managedLocations)

            if offer.receiversPublicKey == nil {
                let offerKeyPair = ManagedKeyPair(context: context)
                offerKeyPair.publicKey = offerPublicKey
                offerKeyPair.receiversOffer = offer
            }

            switch GroupUUID(rawValue: groupUuid) {
            case .none:
                break
            case let .id(uuid):
                @Inject var persistence: PersistenceStoreManagerType
                let group = persistence
                    .loadSyncroniously(type: ManagedGroup.self, context: context, predicate: NSPredicate(format: "uuid == '\(uuid)'"))
                    .first
                offer.group = group
            }

            if offer.inbox == nil {
                offer.inbox = userInbox
            }

            return offer
        } catch {
            return nil
        }
    }
}

private extension OfferPayload {
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
