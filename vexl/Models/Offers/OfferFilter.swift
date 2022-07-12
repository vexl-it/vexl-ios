//
//  OfferFilter.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 24.05.2022.
//

import Foundation

struct OfferFilter: Equatable {
    let type: OfferType
    var currentAmountRange: ClosedRange<Int>?
    var selectedFeeOption: OfferFeeOption = .withoutFee
    var feeAmount: Double = 0
    var locations: [OfferLocationItemData] = []
    var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []
    var selectedBTCOptions: [OfferAdvancedBTCOption] = []
    var selectedFriendDegreeOption: OfferAdvancedFriendDegreeOption = .firstDegree

    mutating func reset(with amountRange: ClosedRange<Int>?) {
        currentAmountRange = amountRange
        selectedFeeOption = .withoutFee
        feeAmount = 0
        locations = []
        selectedPaymentMethodOptions = []
        selectedBTCOptions = []
        selectedFriendDegreeOption = .firstDegree
    }

    func shouldShow(offer: Offer) -> Bool {
        [
            isInRange(offer: offer),
            hasSameFeeOption(offer: offer),
            hasSameFeeValue(offer: offer),
            hasSameLocations(offer: offer),
            hasSamePaymentMethods(offer: offer),
            hasSameBTCOptions(offer: offer),
            hasSameFriendDegree(offer: offer)
        ].allSatisfy { $0 }
    }

    private func isInRange(offer: Offer) -> Bool {
        guard let amountRange = currentAmountRange else { return true }
        return Int(offer.minAmount) >= amountRange.lowerBound && Int(offer.maxAmount) <= amountRange.upperBound
    }

    private func hasSameFeeOption(offer: Offer) -> Bool {
        offer.feeState == selectedFeeOption
    }

    private func hasSameFeeValue(offer: Offer) -> Bool {
        guard offer.feeState == .withFee else { return true }
        return offer.feeAmount.rounded() == feeAmount.rounded()
    }

    private func hasSameLocations(offer: Offer) -> Bool {
        true
    }

    private func hasSamePaymentMethods(offer: Offer) -> Bool {
        guard !selectedPaymentMethodOptions.isEmpty else { return true }
        let offerSet = Set(offer.paymentMethods)
        let filterSet = Set(selectedPaymentMethodOptions)
        return filterSet.isSubset(of: offerSet)
    }

    private func hasSameBTCOptions(offer: Offer) -> Bool {
        guard !selectedBTCOptions.isEmpty else { return true }
        let offerSet = Set(offer.btcNetwork)
        let filterSet = Set(selectedBTCOptions)
        return filterSet.isSubset(of: offerSet)
    }

    private func hasSameFriendDegree(offer: Offer) -> Bool {
        offer.friendLevel == selectedFriendDegreeOption
    }
}

extension OfferFilter {
    static var stub: OfferFilter = OfferFilter(type: .buy)
}
