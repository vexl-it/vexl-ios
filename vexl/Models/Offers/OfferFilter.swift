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
    var feeAmount: Double = 0
    var locations: [OfferLocationItemData] = []
    var selectedPaymentMethodOptions: [OfferPaymentMethodOption] = []
    var selectedBTCOptions: [OfferAdvancedBTCOption] = []
    var selectedFriendDegreeOptions: [OfferFriendDegree] = []
    var currency: Currency?

    var predicate: NSPredicate {
        let userPredicate = NSPredicate(format: "user == nil")
        let offerPredicate = NSPredicate(format: "offerTypeRawType == %@", type.rawValue)

        var predicateList = [userPredicate, offerPredicate]

        if let currency = currency {
            predicateList.append(NSPredicate(format: "currencyRawType == %@", currency.rawValue))
        }

        let feePredicates = selectedFeeOptions.map { feeOption in
            NSPredicate(format: "feeStateRawType == %@", feeOption.rawValue)
        }

        if !feePredicates.isEmpty {
            let feePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: feePredicates)
            predicateList.append(feePredicate)
        }

        let friendDegreePredicates = selectedFriendDegreeOptions.map { friendDegree in
            NSPredicate(format: "friendDegreeRawType == %@", friendDegree.rawValue)
        }

        if !friendDegreePredicates.isEmpty {
            let friendDegreePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: friendDegreePredicates)
            predicateList.append(friendDegreePredicate)
        }

        if let currentAmountRange = currentAmountRange {
            predicateList.append(NSPredicate(format: "maxAmount <= %d", currentAmountRange.upperBound))
            predicateList.append(NSPredicate(format: "minAmount >= %d", currentAmountRange.lowerBound))
        }

        if !selectedPaymentMethodOptions.isEmpty {
            selectedPaymentMethodOptions.forEach { option in
                switch option {
                case .cash:
                    predicateList.append(NSPredicate(format: "acceptsCash == YES"))
                case .revolut:
                    predicateList.append(NSPredicate(format: "acceptsRevolut == YES"))
                case .bank:
                    predicateList.append(NSPredicate(format: "acceptsBankTransfer == YES"))
                }
            }
        }

        if !selectedBTCOptions.isEmpty {
            selectedBTCOptions.forEach { option in
                switch option {
                case .onChain:
                    predicateList.append(NSPredicate(format: "acceptsOnChain == YES"))
                case .lightning:
                    predicateList.append(NSPredicate(format: "acceptsOnLighting == YES"))
                }
            }
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicateList)
    }

    mutating func reset(with amountRange: ClosedRange<Int>?) {
        currentAmountRange = amountRange
        selectedFeeOptions = []
        feeAmount = 0
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
