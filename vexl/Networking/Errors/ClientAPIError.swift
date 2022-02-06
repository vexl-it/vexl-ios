//
//  ClientAPIError.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

enum ClientAPIError: Error {
    case userError(UserError)
    case unknown

    static func parse(code: Int) -> ClientAPIError {
        switch code {
        case 100_000:
            return .userError(.invalidEmail)
        default:
            return .unknown
        }
    }
}

extension ClientAPIError: LocalizedError {
    var errorDescription: String? {
        #warning("Careful with non-localize strings")
        switch self {
        case .userError(let error):
            return error.localizedDescription
        case .unknown:
            fatalError("This should have been localized")
        }
    }
}
