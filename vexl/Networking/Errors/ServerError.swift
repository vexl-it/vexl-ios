//
//  ServerError.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

enum ServerError: Error {
    case invalidResponse(message: String?)
    case invalidRequest
    case timeout
    case missingToken
    case badRequest
    case unauthorized
    case accessDenied
    case notFound
    case internalError
}

extension ServerError: LocalizedError {
    var errorDescription: String? {
        #warning("Careful with non-localize strings")
        switch self {
        case .invalidResponse(let message):
            return message
        case .timeout:
            fatalError("This should have been localized")
        case .internalError:
            fatalError("This should have been localized")
        default:
            return nil
        }
    }
}
