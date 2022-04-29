//
//  OfferData.swift
//  vexl
//
//  Created by Diego Espinoza on 27/04/22.
//

import Foundation

struct OfferInitialData {
    let minOffer: Int
    let maxOffer: Int

    let minFee: Double
    let maxFee: Double

    let currencySymbol: String

    static var defaultValues: OfferInitialData {
        OfferInitialData(minOffer: 0,
                  maxOffer: 100_000,
                  minFee: 1,
                  maxFee: 25,
                  currencySymbol: "$")
    }
}
