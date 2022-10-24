//
//  Offer.swift
//  vexl
//
//  Created by Thành Đỗ Long on 26.08.2022.
//

import Foundation

struct Offer: Equatable {
    var isActive: Bool
    var description: String
    var currency: Currency?
    var amountRange: ClosedRange<Int> = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer
    var currentAmountRange: ClosedRange<Int>
    var selectedFeeOption: OfferFeeOption
    var feeAmount: Double
    var selectedTradeStyleOption: OfferTradeLocationOption
    var selectedPaymentMethodOptions: [OfferPaymentMethodOption]
    var selectedBTCOption: [OfferAdvancedBTCOption]
    var selectedFriendDegreeOption: OfferFriendDegree
    var selectedPriceTrigger: OfferTrigger
    var selectedPriceTriggerAmount: String
    var selectedGroup: ManagedGroup?

    var calculatedAmountRange: ClosedRange<Int> {
        let min = currentAmountRange.lowerBound * currencyStepValue
        let max = currentAmountRange.upperBound * currencyStepValue
        return min...max
    }

    private var currencyStepValue: Int {
        currency == .czk ? Constants.OfferInitialData.maxOfferCZKStep : Constants.OfferInitialData.maxOfferStep
    }

    init(isActive: Bool = true,
         description: String = "",
         currency: Currency = UserDefaultsConfig.selectedCurrency,
         currentAmountRange: ClosedRange<Int> = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer,
         selectedFeeOption: OfferFeeOption = .withoutFee,
         feeAmount: Double = Constants.OfferInitialData.minFee,
         selectedTradeStyleOption: OfferTradeLocationOption = .online,
         selectedPaymentMethodOptions: [OfferPaymentMethodOption] = [],

         selectedBTCOption: [OfferAdvancedBTCOption] = [],
         selectedFriendDegreeOption: OfferFriendDegree = .firstDegree,
         selectedPriceTrigger: OfferTrigger = .none,
         selectedPriceTriggerAmount: String = "") {
        self.isActive = isActive
        self.description = description
        self.currency = currency
        self.currentAmountRange = currentAmountRange
        self.selectedFeeOption = selectedFeeOption
        self.feeAmount = feeAmount
        self.selectedTradeStyleOption = selectedTradeStyleOption
        self.selectedPaymentMethodOptions = selectedPaymentMethodOptions
        self.selectedBTCOption = selectedBTCOption
        self.selectedFriendDegreeOption = selectedFriendDegreeOption
        self.selectedPriceTrigger = selectedPriceTrigger
        self.selectedPriceTriggerAmount = selectedPriceTriggerAmount
        self.update(newCurrency: currency, resetAmount: true)
    }

    init?(managedOffer: ManagedOffer?) {
        guard let managedOffer = managedOffer else { return nil }
        isActive = managedOffer.active
        description = managedOffer.offerDescription ?? ""
        currency = managedOffer.currency ?? UserDefaultsConfig.selectedCurrency
        currentAmountRange = Int(managedOffer.minAmount)...Int(managedOffer.maxAmount)
        selectedFeeOption = managedOffer.feeState ?? .withoutFee
        feeAmount = managedOffer.feeAmount
        selectedTradeStyleOption = managedOffer.locationState ?? .personal
        selectedPaymentMethodOptions = managedOffer.paymentMethods
        selectedBTCOption = managedOffer.btcNetworks
        selectedFriendDegreeOption = managedOffer.friendLevel ?? .firstDegree
        selectedPriceTrigger = managedOffer.activePriceState ?? .none
        selectedPriceTriggerAmount = "\(Int(managedOffer.activePriceValue))"
        selectedGroup = managedOffer.group
        self.update(newCurrency: currency, resetAmount: false)
    }

    mutating func update(with managedOffer: ManagedOffer) {
        let minAmount = Int(managedOffer.minAmount) / currencyStepValue
        let maxAmount = Int(managedOffer.maxAmount) / currencyStepValue
        isActive = managedOffer.active
        description = managedOffer.offerDescription ?? ""
        currency = managedOffer.currency ?? .usd
        currentAmountRange = minAmount...maxAmount
        selectedFeeOption = managedOffer.feeState ?? .withoutFee
        feeAmount = managedOffer.feeAmount
        selectedTradeStyleOption = managedOffer.locationState ?? .personal
        selectedPaymentMethodOptions = managedOffer.paymentMethods
        selectedBTCOption = managedOffer.btcNetworks
        selectedFriendDegreeOption = managedOffer.friendLevel ?? .firstDegree
        selectedPriceTrigger = managedOffer.activePriceState ?? .none
        selectedPriceTriggerAmount = "\(Int(managedOffer.activePriceValue))"
        selectedGroup = managedOffer.group
        self.update(newCurrency: currency, resetAmount: false)
    }

    mutating func setRange(_ range: ClosedRange<Int>) {
        let min = range.lowerBound / currencyStepValue
        let max = range.upperBound / currencyStepValue
        self.currentAmountRange = min...max
    }

    mutating func update(newCurrency: Currency?, resetAmount: Bool) {
        switch currency {
        case .eur, .usd:
            amountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer
            if resetAmount { currentAmountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOffer }
        case .czk:
            amountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOfferCZK
            if resetAmount { currentAmountRange = Constants.OfferInitialData.minOffer...Constants.OfferInitialData.maxOfferCZK }
        case .none:
            break
        }
    }
}
