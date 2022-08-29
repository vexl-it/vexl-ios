//
//  PhoneRegistrationData.swift
//  vexl
//
//  Created by Diego Espinoza on 29/08/22.
//

import Foundation

struct PhoneRegistrationData: Codable {
    var phone: String
    var verification: PhoneVerification
}
