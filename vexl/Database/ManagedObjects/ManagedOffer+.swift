//
//  ManagedOffer+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation
import Combine

extension ManagedOffer {
    var currency: Currency? {
        get { currencyRawType.flatMap(Currency.init) }
        set { currencyRawType = newValue?.rawValue }
    }

    var groupUuid: GroupUUID? {
        get { group?.uuid.flatMap(GroupUUID.id) ?? GroupUUID.none }
    }

    var feeState: OfferFeeOption? {
        get { feeStateRawType.flatMap(OfferFeeOption.init) }
        set { feeStateRawType = newValue?.rawValue }
    }

    var locationState: OfferTradeLocationOption? {
        get { locationStateRawType.flatMap(OfferTradeLocationOption.init) }
        set { locationStateRawType = newValue?.rawValue }
    }

    var paymentMethods: [OfferPaymentMethodOption] {
        get {
            [
                acceptsCash ? .cash : nil,
                acceptsRevolut ? .revolut : nil,
                acceptsBankTransfer ? .bank : nil
            ].compactMap { $0 }
        }
        set {
            let set = Set(newValue)
            acceptsCash = set.contains(.cash)
            acceptsRevolut = set.contains(.revolut)
            acceptsBankTransfer = set.contains(.bank)
        }
    }

    var paymentMethodsPublisher: AnyPublisher<[OfferPaymentMethodOption], Never> {
        Publishers.CombineLatest3(
                publisher(for: \.acceptsCash),
                publisher(for: \.acceptsRevolut),
                publisher(for: \.acceptsBankTransfer)
        )
        .asVoid()
        .withUnretained(self)
        .map(\.paymentMethods)
        .eraseToAnyPublisher()
    }

    var btcNetworks: [OfferAdvancedBTCOption] {
        get {
            [
                acceptsOnChain ? .onChain : nil,
                acceptsOnLighting ? .lightning : nil
            ].compactMap { $0 }
        }
        set {
            let set = Set(newValue)
            acceptsOnChain = set.contains(.onChain)
            acceptsOnLighting = set.contains(.lightning)
        }
    }

    var btcNetworksPublisher: AnyPublisher<[OfferAdvancedBTCOption], Never> {
        Publishers.CombineLatest(
            publisher(for: \.acceptsOnChain),
            publisher(for: \.acceptsOnLighting)
        )
        .asVoid()
        .withUnretained(self)
        .map(\.btcNetworks)
        .eraseToAnyPublisher()
    }

    var friendLevel: OfferFriendDegree? {
        get { friendDegreeRawType.flatMap(OfferFriendDegree.init) }
        set { friendDegreeRawType = newValue?.rawValue }
    }

    var type: OfferType? {
        get { offerTypeRawType.flatMap(OfferType.init) }
        set { offerTypeRawType = newValue?.rawValue }
    }

    var activePriceState: OfferTrigger? {
        get { activePriceStateRawType.flatMap(OfferTrigger.init) }
        set { activePriceStateRawType = newValue?.rawValue }
    }
}

extension ManagedOffer {
    static var stub: ManagedOffer {
        let offer = ManagedOffer()
        offer.isRequested = false

        offer.id = "21"
        offer.createdAt = Date()
        offer.modifiedAt = ""
        offer.currency = .usd
        offer.minAmount = 0
        offer.maxAmount = 10_000
        offer.feeAmount = 590
        offer.offerDescription = "Test"
        offer.feeState = .none
        offer.locationState = .online
        offer.friendLevel = .firstDegree
        offer.type = .sell
        offer.active = true
        offer.activePriceState = OfferTrigger.none
        offer.activePriceValue = 12
        offer.paymentMethods = [.bank, .cash]
        offer.btcNetworks = [.lightning]

        return offer
    }
}
