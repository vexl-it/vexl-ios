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
    var locations: [OfferLocationItemData] = []
    var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []
    var selectedBTCOptions: [OfferAdvancedBTCOption] = []
    var selectedFriendDegreeOptions: [OfferFriendDegree] = []
    var selectedGroups: [ManagedGroup] = []
    var currency: Currency?

    var predicate: NSPredicate {
        let userPredicate = NSPredicate(format: "user == nil")
        let offerPredicate = NSPredicate(format: "offerTypeRawType == %@", type.rawValue)
        let activePredicate = NSPredicate(format: "active == TRUE")

        var predicateList = [userPredicate, offerPredicate, activePredicate]

        if let currency = currency {
            predicateList.append(NSPredicate(format: "currencyRawType == %@", currency.rawValue))
        }

        if !selectedFeeOptions.isEmpty {
            let feePredicates = selectedFeeOptions
                .map { NSPredicate(format: "feeStateRawType == %@", $0.rawValue) }
            predicateList.append(NSCompoundPredicate(orPredicateWithSubpredicates: feePredicates))

            if selectedFeeOptions.contains(.withFee) {
                predicateList.append(NSPredicate(format: "feeAmount <= \(feeAmount)"))
            }
        }

        if !selectedFriendDegreeOptions.isEmpty {
            let friendDegreePredicates = selectedFriendDegreeOptions
                .map { NSPredicate(format: "friendDegreeRawType == %@", $0.rawValue) }
            predicateList.append(NSCompoundPredicate(orPredicateWithSubpredicates: friendDegreePredicates))
        }

        if let currentAmountRange = currentAmountRange {
            let amountRangePredicate: [NSPredicate] = [
                NSPredicate(format: "maxAmount >= %d AND maxAmount <= %d", currentAmountRange.lowerBound, currentAmountRange.upperBound),
                NSPredicate(format: "minAmount >= %d AND minAmount <= %d", currentAmountRange.lowerBound, currentAmountRange.upperBound),
                NSPredicate(format: "%d >= minAmount AND %d <= maxAmount", currentAmountRange.lowerBound, currentAmountRange.lowerBound),
                NSPredicate(format: "%d >= minAmount AND %d <= maxAmount", currentAmountRange.upperBound, currentAmountRange.upperBound)
            ]
            predicateList.append(NSCompoundPredicate(orPredicateWithSubpredicates: amountRangePredicate))
        }

        if !selectedPaymentMethodOptions.isEmpty {
            let paymentMethodPredicates: [NSPredicate] = selectedPaymentMethodOptions.map { option in
                switch option {
                case .cash:
                    return NSPredicate(format: "acceptsCash == YES")
                case .revolut:
                    return NSPredicate(format: "acceptsRevolut == YES")
                case .bank:
                    return NSPredicate(format: "acceptsBankTransfer == YES")
                }
            }
            predicateList.append(NSCompoundPredicate(orPredicateWithSubpredicates: paymentMethodPredicates))
        }

        if !selectedBTCOptions.isEmpty {
            let btcOptionPredicates: [NSPredicate] = selectedBTCOptions.map { option in
                switch option {
                case .onChain:
                    return NSPredicate(format: "acceptsOnChain == YES")
                case .lightning:
                    return NSPredicate(format: "acceptsOnLighting == YES")
                }
            }
            predicateList.append(NSCompoundPredicate(orPredicateWithSubpredicates: btcOptionPredicates))
        }

        if !selectedGroups.isEmpty {
            let groupPredicates = selectedGroups
                .map { NSPredicate(format: "group == %@", $0) }
            predicateList.append(NSCompoundPredicate(orPredicateWithSubpredicates: groupPredicates))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicateList)
    }

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
}

extension OfferFilter {
    static var stub: OfferFilter = OfferFilter(type: .buy)
}
