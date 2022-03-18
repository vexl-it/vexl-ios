//
//  PhoneConfirmation.swift
//  vexl
//
//  Created by Diego Espinoza on 18/03/22.
//

import Foundation

struct PhoneConfirmationResponse: Codable {
    var verificationId: Int
    var expirationAt: Date 
}
