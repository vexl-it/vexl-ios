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
