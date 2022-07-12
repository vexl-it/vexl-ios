//
//  RegistryError.swift
//  vexl
//
//  Created by Diego Espinoza on 30/03/22.
//

import Foundation

enum RegistryError: Error {
    case invalidValidationCode
    case invalidChallenge
}

extension RegistryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidValidationCode:
            return L.errorRegisterInvalidValidationCode()
        case .invalidChallenge:
            return L.errorRegisterInvalidChallenge()
        }
    }
}
