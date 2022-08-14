//
//  Currency.swift
//  vexl
//
//  Created by Adam Salih on 22.06.2022.
//

import Foundation

enum HorizontalPosition {
    case left
    case right
}

enum Currency: String, Codable, CaseIterable, Identifiable {
    var id: Int { self.rawValue.hashValue }

    case czk = "CZK"
    case eur = "EUR"
    case usd = "USD"

    var sign: String {
        switch self {
        case .eur:
            return "€"
        case .usd:
            return "$"
        case .czk:
            return "Kč"
        }
    }

    var position: HorizontalPosition {
        switch self {
        case .eur:
            return .right
        case .usd:
            return .left
        case .czk:
            return .right
        }
    }

    var title: String {
        switch self {
        case .eur:
            return L.userProfileCurrencyEur()
        case .usd:
            return L.userProfileCurrencyUsd()
        case .czk:
            return L.userProfileCurrencyCzk()
        }
    }

    var label: String {
        switch self {
        case .usd:
            return L.offerCurrencyUsdTitle()
        case .eur:
            return L.offerCurrencyEurTitle()
        case .czk:
            return L.offerCurrencyCzkTitle()
        }
    }

    func formattedCurrency(amount: Int) -> String {
        // TODO: Discuss if we want to use number formatters here
        switch position {
        case .left:
            return "\(sign) \(amount)"
        case .right:
            return "\(amount) \(sign)"
        }
    }

    func formattedShortCurrency(amount: Double) -> String {
        // TODO: Discuss if we want to use number formatters here
        var amount = amount
        let isBigNumber = amount > 1_000
        amount = isBigNumber ? amount / 1_000 : amount
        let formattedAmount = Formatters.shortNumberFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        let postFix = isBigNumber ? L.marketplaceSignForThousand() : ""
        switch position {
        case .left:
            return "\(sign) \(formattedAmount)\(postFix)"
        case .right:
            return "\(formattedAmount)\(postFix) \(sign)"
        }
    }
}
