//
//  UserError.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

enum UserError: Error {
    case invalidEmail
    case unavailableUsername
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return L.errorRegisterInvalidEmail()
        case .unavailableUsername:
            return L.errorRegisterInvalidUsername()
        }
    }
}
