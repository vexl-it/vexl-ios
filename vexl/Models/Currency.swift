//
//  Currency.swift
//  vexl
//
//  Created by Adam Salih on 22.06.2022.
//

import Foundation

enum Currency: String, Codable {
    case eur = "EUR"
    case usd = "USD"
    case czk = "CZK"

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
}
