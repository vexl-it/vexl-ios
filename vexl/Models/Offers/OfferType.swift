//
//  OfferType.swift
//  vexl
//
//  Created by Diego Espinoza on 29/06/22.
//

import Foundation

struct OfferTypeOption: OptionSet {
    let rawValue: Int

    static let sell = OfferTypeOption(rawValue: 1 << 0)
    static let buy = OfferTypeOption(rawValue: 1 << 1)

    static let all: OfferTypeOption = [.sell, .buy]
}

enum OfferType: String {
    case sell = "SELL"
    case buy = "BUY"

    var title: String {
        switch self {
        case .sell:
            return L.marketplaceSell()
        case .buy:
            return L.marketplaceBuy()
        }
    }

    var inversePerspecitve: OfferType {
        switch self {
        case .sell:
            return .buy
        case .buy:
            return .sell
        }
    }
}
