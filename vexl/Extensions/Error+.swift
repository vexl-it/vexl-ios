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
            #warning("Careful with non-localize strings")
            fatalError("This should have been localized")
        } else if let localizedError = self as? LocalizedError, let errorDescription = localizedError.errorDescription {
            return errorDescription
        } else {
            return localizedDescription
        }
    }
}

struct AlertError: Identifiable {
    let id: Int
    var error: Error

    var message: String {
        error.getMessage()
    }

    init(id: Int, error: Error) {
        self.error = error
        self.id = id
    }
}
