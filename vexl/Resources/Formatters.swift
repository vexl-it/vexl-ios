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

    /// format: yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ
    /// example: 2022-06-22T11:29:00.000GMT+02:00
    static let dateApiFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// format: E dd.MM HH:mm
    /// example: Mon 12.10. 12:30
    static let chatDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd.MM HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// format: d. MMM
    /// example: 12. Jun
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// format: HH:mm
    /// example: 12:30
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let phoneNumberFormatter = PhoneNumberKit()

    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.currencyCode = "USD"
        formatter.numberStyle = .currency
        return formatter
    }()
}
