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
    var selectedFeeOptions: [OfferFeeOption] = []
    var feeAmount: Double = 1
    var locations: [OfferLocation] = []
    var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []
    var selectedBTCOptions: [OfferAdvancedBTCOption] = []
    var selectedFriendDegreeOptions: [OfferFriendDegree] = []
    var selectedGroups: [ManagedGroup] = []
    var currency: Currency?

    var isFilterEmpty: Bool {
        currency == nil &&
        selectedFeeOptions.isEmpty &&
        locations.isEmpty &&
        selectedPaymentMethodOptions.isEmpty &&
        selectedBTCOptions.isEmpty &&
        selectedFriendDegreeOptions.isEmpty
    }

    mutating func reset(with amountRange: ClosedRange<Int>?) {
        currentAmountRange = amountRange
        selectedFeeOptions = []
        feeAmount = 1
        locations = []
        selectedPaymentMethodOptions = []
        selectedBTCOptions = []
        selectedFriendDegreeOptions = []
        currency = nil
    }

    var predicate: NSPredicate {
        @Inject var cryptoManager: CryptocurrencyValueManagerType
        let userPredicate = NSPredicate(format: "user == nil")
        let offerPredicate = NSPredicate(format: "offerTypeRawType == %@", type.rawValue)
        let activePredicate = NSPredicate(format: "active == TRUE")

        var predicateList = [userPredicate, offerPredicate, activePredicate]

        if let currency = currency {
            predicateList.append(NSPredicate(format: "currencyRawType == %@", currency.rawValue))
        }

        if let coinData = cryptoManager.currentCoinData.value.data {
            predicateList.append(generatePredicatesForActivePriceTrigger(coinData: coinData))
        }

        if !selectedFeeOptions.isEmpty {
            predicateList.append(generatePredicatesForFeeOptions())
        }

        if !selectedFriendDegreeOptions.isEmpty {
            predicateList.append(generatePredicatesForFriendDegree())
        }

        if let currentAmountRange = currentAmountRange {
            predicateList.append(generatePredicatesForAmmountRange(currentAmountRange: currentAmountRange))
        }

        if !selectedPaymentMethodOptions.isEmpty {
            predicateList.append(generatePredicatesForPaymmentMethods())
        }

        if !selectedBTCOptions.isEmpty {
            predicateList.append(generatePredicatesForBTCOptions())
        }

        if !selectedGroups.isEmpty {
            predicateList.append(generatePredicatesForGroups())
        }

        if !locations.isEmpty {
            predicateList.append(generatePredicatesForLocations())
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicateList)
    }

    private func generatePredicatesForActivePriceTrigger(coinData: CoinData) -> NSPredicate {
        let activePriceAbovePredicate = NSPredicate(format: "activePriceStateRawType == '\(OfferTrigger.above.rawValue)'")
        let activePriceAbovePredicates = Currency.allCases.map { currency -> NSPredicate in
            let priceDecimal: Decimal = coinData.price(for: currency)
            let price = Double(truncating: priceDecimal as NSNumber)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "activePriceValue < \(price)"),
                NSPredicate(format: "activePriceCurrencyRawType == '\(currency.rawValue)'"),
                activePriceAbovePredicate
            ])
        }

        let activePriceBelowPredicate = NSPredicate(format: "activePriceStateRawType == '\(OfferTrigger.below.rawValue)'")
        let activePriceBelowPredicates = Currency.allCases.map { currency -> NSPredicate in
            let priceDecimal: Decimal = coinData.price(for: currency)
            let price = Double(truncating: priceDecimal as NSNumber)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "activePriceValue > \(price)"),
                NSPredicate(format: "activePriceCurrencyRawType == '\(currency.rawValue)'"),
                activePriceBelowPredicate
            ])
        }

        let nonePredicate = NSPredicate(format: "activePriceStateRawType == '\(OfferTrigger.none.rawValue)'")

        return NSCompoundPredicate(orPredicateWithSubpredicates: activePriceAbovePredicates + activePriceBelowPredicates + [nonePredicate])
    }

    private func generatePredicatesForFeeOptions() -> NSPredicate {
        let feePredicates = selectedFeeOptions
            .map { NSPredicate(format: "feeStateRawType == %@", $0.rawValue) }

        var feeStatePredicates: [NSPredicate] = [
            NSCompoundPredicate(orPredicateWithSubpredicates: feePredicates)
        ]

        if selectedFeeOptions.contains(.withFee) {
            feeStatePredicates.append(NSPredicate(format: "feeAmount <= \(feeAmount)"))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates:feeStatePredicates)
    }

    private func generatePredicatesForFriendDegree() -> NSPredicate {
        NSCompoundPredicate(
            orPredicateWithSubpredicates: selectedFriendDegreeOptions
                .map { NSPredicate(format: "friendDegreeRawType == %@", $0.rawValue) }
        )
    }

    private func generatePredicatesForAmmountRange(currentAmountRange: ClosedRange<Int>) -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "maxAmount >= %d AND maxAmount <= %d", currentAmountRange.lowerBound, currentAmountRange.upperBound),
            NSPredicate(format: "minAmount >= %d AND minAmount <= %d", currentAmountRange.lowerBound, currentAmountRange.upperBound),
            NSPredicate(format: "%d >= minAmount AND %d <= maxAmount", currentAmountRange.lowerBound, currentAmountRange.lowerBound),
            NSPredicate(format: "%d >= minAmount AND %d <= maxAmount", currentAmountRange.upperBound, currentAmountRange.upperBound)
        ])
    }

    private func generatePredicatesForPaymmentMethods() -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: selectedPaymentMethodOptions
            .map { option in
                switch option {
                case .cash:
                    return NSPredicate(format: "acceptsCash == YES")
                case .revolut:
                    return NSPredicate(format: "acceptsRevolut == YES")
                case .bank:
                    return NSPredicate(format: "acceptsBankTransfer == YES")
                }
            }
        )
    }

    private func generatePredicatesForBTCOptions() -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: selectedBTCOptions
            .map { option in
                switch option {
                case .onChain:
                    return NSPredicate(format: "acceptsOnChain == YES")
                case .lightning:
                    return NSPredicate(format: "acceptsOnLighting == YES")
                }
            }
        )
    }

    private func generatePredicatesForGroups() -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: selectedGroups
            .map { NSPredicate(format: "group == %@", $0) }
        )
    }

    private func generatePredicatesForLocations() -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: locations
            .map { NSPredicate(format: "ANY locations.city == %@", $0.city) }
        )
    }
}

extension OfferFilter {
    static var stub: OfferFilter = OfferFilter(type: .buy)
}
