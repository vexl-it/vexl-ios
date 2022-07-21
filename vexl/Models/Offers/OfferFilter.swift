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

    var predicate: NSPredicate {
        var format = """
            offerTypeRawType == '\(type.rawValue)'
        AND feeStateRawType == '\(selectedFeeOption.rawValue)'
        AND friendDegreeRawType == '\(selectedFriendDegreeOption.rawValue)'
        """

        if selectedFeeOption == .withFee {
            format += """
                AND feeAmount == \(feeAmount)
            """
        }

        if let currentAmountRange = currentAmountRange {
            format += """
            AND maxAmount <= \(currentAmountRange.upperBound)
            AND minAmount >= \(currentAmountRange.lowerBound)
            """
        }

        // TODO: filter location

        if !selectedPaymentMethodOptions.isEmpty {
            let paymentPredicates = selectedPaymentMethodOptions.map(\.rawValue)
                .map { rawValue in
                    "'\(rawValue)'"
                }
                .joined(separator: ", ") + " IN paymentMethodRawTypes "

            format += """
                AND \(paymentPredicates)
            """
        }

        if !selectedBTCOptions.isEmpty {
            let paymentPredicates = selectedBTCOptions.map(\.rawValue)
                .map { rawValue in
                    "'\(rawValue)'"
                }
                .joined(separator: ", ") + " IN paymentMethodRawTypes "

            format += "AND \(paymentPredicates)"
        }

        return NSPredicate(format: format)
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
