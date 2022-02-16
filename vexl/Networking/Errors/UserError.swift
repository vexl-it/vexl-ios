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
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        #warning("Careful with non-localize strings")
        switch self {
        case .invalidEmail:
            fatalError("This should have been localized")
        }
    }
}
