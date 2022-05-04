//
//  Formatters.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation
import PhoneNumberKit

struct Formatters {
    // MARK: - Date API

    static let dateApiFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let phoneNumberFormatter = PhoneNumberKit()
    static let phoneNumberPartialFormatter = PartialFormatter()

    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.currencyCode = "USD"
        formatter.numberStyle = .currency
        return formatter
    }()
}
