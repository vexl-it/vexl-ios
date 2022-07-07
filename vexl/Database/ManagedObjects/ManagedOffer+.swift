//
//  ManagedOffer+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation

extension ManagedOffer {
    var feeState: OfferFeeOption? {
        feeStateRawType.flatMap(OfferFeeOption.init)
    }

    var locationState: OfferTradeLocationOption? {
        locationStateRawType.flatMap(OfferTradeLocationOption.init)
    }

    var paymentMethods: [OfferPaymentMethodOption] {
        let methods = paymentMethodRawTypes ?? []
        return methods.compactMap(OfferPaymentMethodOption.init)
    }

    var btcNetworks: [OfferAdvancedBTCOption] {
        let networks = btcNetworkRawTypes ?? []
        return networks.compactMap(OfferAdvancedBTCOption.init)
    }

    var friendLevel: OfferAdvancedFriendDegreeOption? {
        friendLevelRawType.flatMap(OfferAdvancedFriendDegreeOption.init)
    }

    var type: OfferType? {
        offerTypeRawType.flatMap(OfferType.init)
    }

}
