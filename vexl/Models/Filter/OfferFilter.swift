//
//  OfferFilter.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 24.05.2022.
//

import Foundation

struct OfferFilter: Equatable {
    let type: OfferType
    var currentAmountRange: ClosedRange<Int> = 0...100
    var selectedFeeOption: OfferFeeOption = .withoutFee
    var feeAmount: Double = 0
    var locations: [OfferLocationItemData] = []
    var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []
    var selectedBTCOption: [OfferAdvancedBTCOption] = []
    var selectedFriendSources: [OfferAdvancedFriendSourceOption] = []
    var selectedFriendDegreeOption: OfferAdvancedFriendDegreeOption = .firstDegree
}

extension OfferFilter {
    static var stub: OfferFilter = OfferFilter(type: .buy)
}
