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
    var currency: Currency?

    var predicate: NSPredicate {
        let userPredicate = NSPredicate(format: "user == nil")
        let offerPredicate = NSPredicate(format: "offerTypeRawType == %@", type.rawValue)
        let feePredicate = NSPredicate(format: "feeStateRawType == %@", selectedFeeOption.rawValue)
        let friendPredicate = NSPredicate(format: "friendDegreeRawType == %@", selectedFriendDegreeOption.rawValue)

        var predicateList = [userPredicate, offerPredicate, feePredicate, friendPredicate]

        if let currency = currency {
            predicateList.append(NSPredicate(format: "currencyRawType == %@", currency.rawValue))
        }

        if selectedFeeOption == .withFee {
            predicateList.append(NSPredicate(format: "feeAmount == %@", feeAmount))
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
        selectedFeeOption = .withoutFee
        feeAmount = 0
        locations = []
        selectedPaymentMethodOptions = []
        selectedBTCOptions = []
        selectedFriendDegreeOption = .firstDegree
    }
}

extension OfferFilter {
    static var stub: OfferFilter = OfferFilter(type: .buy)
}
