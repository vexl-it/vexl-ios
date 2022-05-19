//
//  UserError.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

enum UserError: Error {
    case invalidPhoneNumber
    case invalidEmail
    case unavailableUsername
    case facebookAccess
    case fetchFacebookFriends
    case facebookValidation
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return L.registerPhoneNumberError()
        case .invalidEmail:
            return L.errorRegisterInvalidEmail()
        case .unavailableUsername:
            return L.errorRegisterInvalidUsername()
        case .facebookAccess:
            return L.errorRegisterFacebookAccess()
        case .fetchFacebookFriends:
            return L.errorRegisterFacebookFriends()
        case .facebookValidation:
            return L.errorRegisterFacebookAccess()
        }
    }
}
