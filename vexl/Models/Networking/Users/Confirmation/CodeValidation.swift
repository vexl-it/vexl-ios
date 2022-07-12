//
//  CodeValidationResponse.swift
//  vexl
//
//  Created by Diego Espinoza on 20/03/22.
//

import Foundation

struct CodeValidation: Decodable {
    var challenge: String
    var phoneVerified: Bool
}
