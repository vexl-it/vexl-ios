//
//  OfferPayload.swift
//  vexl
//
//  Created by Diego Espinoza on 30/04/22.
//

import Foundation
import CoreData

// swiftlint:disable unnecessary_parenthesis

struct OfferPayloadListWrapper: Decodable {
    var offers: [OfferPayload]
}

struct OfferPayloadList: Codable {
    let offerPrivateList: [OfferPayload]

    init(list: [OfferPayload]) {
        self.offerPrivateList = list
    }
}

struct OfferIdList: Codable {
    var offerIds: [String]
}

enum OfferPayloadPrivateVersion: Int {
    case v1 = 0
}

struct OfferPayloadPrivate: Codable {
    var commonFriends: [String]
    var friendLevel: [String]
    var symmetricKey: String
}

struct OfferPayloadPrivateWrapper: Codable {
    var userPublicKey: String
    var payloadPrivate: OfferPayloadPrivate
}

struct OfferPayloadPrivateWrapperEncrypted: Codable {
    let userPublicKey: String
    let payloadPrivate: String

    var asJson: [String: Any] {
        [
            "userPublicKey": userPublicKey,
            "payloadPrivate": payloadPrivate
        ]
    }
}

enum OfferPayloadPublicVersion: Int {
    case v1 = 0
}

struct OfferPayloadPublic: Codable {
    let location: [String]
    let offerPublicKey: String
    let offerDescription: String
    let amountBottomLimit: String
    let amountTopLimit: String
    let feeState: String
    let feeAmount: String
    let locationState: String
    let paymentMethod: [String]
    let btcNetwork: [String]
    let currency: String
    let offerType: String
    let activePriceState: String
    let activePriceValue: String
    let activePriceCurrency: String
    let active: String
    let groupUuids: [String]

    init(offer: ManagedOffer) throws {
        guard
            let offerPublicKey = offer.inbox?.keyPair?.publicKey,
            let description = offer.offerDescription,
            let feeState = offer.feeStateRawType,
            let locationState = offer.locationStateRawType,
            let offerType = offer.offerTypeRawType,
            let activePriceState = offer.activePriceStateRawType,
            let activePriceCurrency = offer.activePriceCurrency?.rawValue,
            let groupUuid = offer.groupUuid?.rawValue,
            let currency = offer.currencyRawType
        else {
            throw EncryptionError.dataEncryption
        }

        let managedLocations = offer.locations?.allObjects as? [ManagedOfferLocation] ?? []
        let locations = managedLocations.compactMap(OfferLocation.init)
        let locationStrings = locations.compactMap { $0.asString }
        self.location = locationStrings

        self.groupUuids = [groupUuid]
        self.offerPublicKey = offerPublicKey
        self.offerDescription = description
        self.amountTopLimit = offer.maxAmount.asString
        self.amountBottomLimit = offer.minAmount.asString
        self.feeState = feeState
        self.feeAmount = offer.feeAmount.asString
        self.locationState = locationState
        self.paymentMethod = offer.paymentMethods.map(\.rawValue)
        self.btcNetwork = offer.btcNetworks.map(\.rawValue)
        self.offerType = offerType
        self.currency = currency
        self.activePriceState = activePriceState
        self.activePriceValue = offer.activePriceValue.asString
        self.activePriceCurrency = activePriceCurrency
        self.active = offer.active.asString
    }
}

struct OfferRequestPayload: Codable {
    let offerType: String
    let expiration: Int
    let payloadPublic: String
    let offerPrivateList: [OfferPayloadPrivateWrapperEncrypted]

    var asJson: [String: Any] {
        [
            "offerType": offerType,
            "expiration": expiration,
            "payloadPublic": payloadPublic,
            "offerPrivateList": offerPrivateList.map(\.asJson)
        ]
    }
}

struct OfferPayload: Codable {
    let offerId: String
    let adminId: String?
    let publicPayload: String
    let privatePayload: String
    let expiration: Int
    let createdAt: Date
    let modifiedAt: Date
}

extension OfferPayload {
    func decryptPublicKey(keyPair: ECCKeys) -> String? {
        guard let (publicPart, _) = decryptParts(keyPair: keyPair) else {
            return nil
        }
        return publicPart.offerPublicKey
    }

    // swiftlint:disable:next function_body_length
    @discardableResult
    func decrypt(context: NSManagedObjectContext,
                 userInbox: ManagedInbox,
                 into offer: ManagedOffer) -> ManagedOffer? {
        guard let keyPair = userInbox.keyPair?.keys,
              let (publicPart, privatePart) = decryptParts(keyPair: keyPair),
              let currency = Currency(rawValue: publicPart.currency),
              let feeState = OfferFeeOption(rawValue: publicPart.feeState),
              let locationState = OfferTradeLocationOption(rawValue: publicPart.locationState),
              let activePriceState = OfferTrigger(rawValue: publicPart.activePriceState),
              let offerType = OfferType(rawValue: publicPart.offerType),
              let activePriceCurrency = Currency(rawValue: publicPart.activePriceCurrency),
              let minAmount = Double(publicPart.amountBottomLimit),
              let maxAmount = Double(publicPart.amountTopLimit),
              let activePrice = Double(publicPart.activePriceValue),
              let feeAmount = Double(publicPart.feeAmount) else {
            return nil
        }
        let friendLevel = privatePart.friendLevel.compactMap(AnonymousProfileType.init)

        offer.offerID = offerId
        offer.adminID = adminId
        offer.createdAt = createdAt
        offer.modifiedAt = Formatters.dateApiFormatter.string(from: modifiedAt)
        offer.currency = currency
        offer.minAmount = minAmount
        offer.maxAmount = maxAmount
        offer.feeAmount = feeAmount
        offer.offerDescription = publicPart.offerDescription
        offer.feeState = feeState
        offer.locationState = locationState
        offer.friendLevels = friendLevel.compactMap(\.asOfferFriendDegree)
        offer.offerTypeRawType = offerType.rawValue
        offer.active = Bool(publicPart.active) ?? false
        offer.activePriceState = activePriceState
        offer.activePriceValue = activePrice
        offer.activePriceCurrency = activePriceCurrency
        offer.paymentMethods = publicPart.paymentMethod.compactMap(OfferPaymentMethodOption.init)
        offer.btcNetworks = publicPart.btcNetwork.compactMap(OfferAdvancedBTCOption.init)
        offer.commonFriends = privatePart.commonFriends

        let offerLocations = publicPart.location.compactMap(OfferLocation.init)
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
            offerKeyPair.publicKey = publicPart.offerPublicKey
            offerKeyPair.receiversOffer = offer
        }

        if let groupUuid = publicPart.groupUuids.first {
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
        }

        if offer.inbox == nil {
            offer.inbox = userInbox
        }

        if friendLevel.contains(.firstDegree) {
            offer.friendLevel = .firstDegree
        } else if friendLevel.contains(.secondDegree) {
            offer.friendLevel = .secondDegree
        } else { // if friendLevel.contains(.group) {
            // TODO: add .group friend level to offer
//                offer.friendLevel = .group
            offer.friendLevel = .secondDegree
        }

        return offer
    }

    private func decryptParts(keyPair: ECCKeys) -> (publicPart: OfferPayloadPublic, privatePart: OfferPayloadPrivate)? {
        guard let (privateVersion, privateCipher) = privatePayload.decodeEncryptionVersion(version: OfferPayloadPrivateVersion.self),
             privateVersion == .v1,
             let privatePartJson = try? privateCipher.ecc.decrypt(keys: keyPair).data(using: .utf8),
             let privatePart = try? Constants.jsonDecoder.decode(OfferPayloadPrivate.self, from: privatePartJson),
             let (publicVersion, publicCipher) = publicPayload.decodeEncryptionVersion(version: OfferPayloadPrivateVersion.self),
             publicVersion == .v1,
             let publicPartJson = try? publicCipher.aes.decrypt(password: privatePart.symmetricKey).data(using: .utf8),
             let publicPart = try? Constants.jsonDecoder.decode(OfferPayloadPublic.self, from: publicPartJson)
        else {
           return nil
        }
        return (publicPart, privatePart)
    }
}
