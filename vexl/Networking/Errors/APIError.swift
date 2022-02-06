//
//  APIError.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

enum APIError: Error {
    case serverError(ServerError)
    case clientError(ClientAPIError, message: String?)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .serverError(let error):
            return error.errorDescription
        case let .clientError(error, message):
            return error.errorDescription ?? message
        }
    }
}
