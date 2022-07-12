//
//  Error+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

extension Error {
    func getMessage() -> String {
        if let urlError = self as? URLError, urlError.code == .notConnectedToInternet {
            return L.generalInternalServerError()
        } else if let localizedError = self as? LocalizedError, let errorDescription = localizedError.errorDescription {
            return errorDescription
        } else {
            return localizedDescription
        }
    }
}
