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
    var selectedFriendDegreeOption: OfferFriendDegree = .firstDegree

    mutating func reset(with amountRange: ClosedRange<Int>?) {
        currentAmountRange = amountRange
        selectedFeeOption = .withoutFee
        feeAmount = 0
        locations = []
        selectedPaymentMethodOptions = []
        selectedBTCOptions = []
        selectedFriendDegreeOption = .firstDegree
    }

    func shouldShow(offer: ManagedOffer) -> Bool {
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

    private func isInRange(offer: ManagedOffer) -> Bool {
        guard let amountRange = currentAmountRange else { return true }
        return Int(offer.minAmount) >= amountRange.lowerBound && Int(offer.maxAmount) <= amountRange.upperBound
    }

    private func hasSameFeeOption(offer: ManagedOffer) -> Bool {
        offer.feeState == selectedFeeOption
    }

    private func hasSameFeeValue(offer: ManagedOffer) -> Bool {
        guard offer.feeState == .withFee else { return true }
        return offer.feeAmount.rounded() == feeAmount.rounded()
    }

    private func hasSameLocations(offer: ManagedOffer) -> Bool {
        true
    }

    private func hasSamePaymentMethods(offer: ManagedOffer) -> Bool {
        guard !selectedPaymentMethodOptions.isEmpty else { return true }
        let offerSet = Set(offer.paymentMethods)
        let filterSet = Set(selectedPaymentMethodOptions)
        return filterSet.isSubset(of: offerSet)
    }

    private func hasSameBTCOptions(offer: ManagedOffer) -> Bool {
        guard !selectedBTCOptions.isEmpty else { return true }
        let offerSet = Set(offer.btcNetworks)
        let filterSet = Set(selectedBTCOptions)
        return filterSet.isSubset(of: offerSet)
    }

    private func hasSameFriendDegree(offer: ManagedOffer) -> Bool {
        offer.friendLevel == selectedFriendDegreeOption
    }
}

extension OfferFilter {
    static var stub: OfferFilter = OfferFilter(type: .buy)
}
