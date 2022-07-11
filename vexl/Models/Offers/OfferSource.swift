//
//  OfferSource.swift
//  vexl
//
//  Created by Diego Espinoza on 29/06/22.
//

import Foundation

struct OfferSourceOption: OptionSet {
    let rawValue: Int

    static let created = OfferSourceOption(rawValue: 1 << 0)
    static let fetched = OfferSourceOption(rawValue: 1 << 1)

    static let all: OfferSourceOption = [.created, .fetched]
}

enum OfferSource: String {
    case created
    case fetched
}

enum OfferTrigger: String {
    case none = "NONE"
    case below = "PRICE_IS_BELOW"
    case above = "PRICE_IS_ABOVE"

    var title: String {
        switch self {
        case .none:
            return ""
        case .above:
            return L.offerCreateTriggerAbove()
        case .below:
            return L.offerCreateTriggerBelow()
        }
    }
 }

enum GroupUUID: RawRepresentable {
    init(rawValue: String) {
        switch rawValue {
        case "NONE":
            self = .none
        default:
            self = .id(rawValue)
        }
    }

    case none
    case id(_ id: String)

    var rawValue: String {
        switch self {
        case .none:
            return "NONE"
        case let .id(id):
            return id
        }
    }
}
