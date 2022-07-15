//
//  ManagedOffer+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation

extension ManagedOffer {
    var currency: Currency? {
        get { currencyRawType.flatMap(Currency.init) }
        set { currencyRawType = newValue?.rawValue }
    }

    var groupUuid: GroupUUID? {
        get { groupUuidRawType.flatMap(GroupUUID.init) }
        set { groupUuidRawType = newValue?.rawValue }
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
            let methods = paymentMethodRawTypes ?? []
            return methods.compactMap(OfferPaymentMethodOption.init)
        }
        set { paymentMethodRawTypes = newValue.map(\.rawValue) }
    }

    var btcNetworks: [OfferAdvancedBTCOption] {
        get {
            let networks = btcNetworkRawTypes ?? []
            return networks.compactMap(OfferAdvancedBTCOption.init)
        }
        set { btcNetworkRawTypes = newValue.map(\.rawValue) }
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
