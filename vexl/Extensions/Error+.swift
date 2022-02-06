//
//  Error+.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation

extension Error {
    func getMessage() -> String {
        if let urlError = self as? URLError, urlError.code == .notConnectedToInternet {
            #warning("Careful with non-localize strings")
            fatalError("This should have been localized")
        } else if let localizedError = self as? LocalizedError, let errorDescription = localizedError.errorDescription {
            return errorDescription
        } else {
            return localizedDescription
        }
    }
}
