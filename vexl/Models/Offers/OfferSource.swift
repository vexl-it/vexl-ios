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

enum OfferFriendDegree: String, CaseIterable {
    case firstDegree = "FIRST_DEGREE"
    case secondDegree = "SECOND_DEGREE"

    var degree: Int {
        switch self {
        case .firstDegree:
            return 1
        case .secondDegree:
            return 2
        }
    }

    var imageName: String {
        switch self {
        case .firstDegree:
            return R.image.offer.firstDegree.name
        case .secondDegree:
            return R.image.offer.secondDegree.name
        }
    }

    var label: String {
        switch self {
        case .firstDegree:
            return L.marketplaceDetailFriendFirst()
        case .secondDegree:
            return L.marketplaceDetailFriendSecond()
        }
    }

    var convertToContactFriendLevel: ContactFriendLevel {
        switch self {
        case .firstDegree:
            return .first
        case .secondDegree:
            return .second
        }
    }
}
