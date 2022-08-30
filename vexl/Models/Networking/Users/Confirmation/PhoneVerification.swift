//
//  PhoneConfirmation.swift
//  vexl
//
//  Created by Diego Espinoza on 18/03/22.
//

import Foundation

struct PhoneVerification: Codable {
    var verificationId: Int
    var expirationAt: String

    var expirationDate: Date? {
        Formatters.dateApiFormatter.date(from: expirationAt)
    }
}
