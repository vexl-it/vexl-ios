//
//  PhoneRegistrationData.swift
//  vexl
//
//  Created by Diego Espinoza on 29/08/22.
//

import Foundation

class PhoneRegistrationData: Codable {
    private var content: [String: PhoneVerification] = [:]

    func add(phone: String, verification: PhoneVerification) {
        content[phone] = verification
    }

    func getVerification(forPhone phone: String) -> PhoneVerification? {
        content[phone]
    }

    func removeAll() {
        content = [:]
    }
}
