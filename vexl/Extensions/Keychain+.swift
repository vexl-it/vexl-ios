//
//  Keychain+.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import KeychainAccess

extension Keychain {
    static let standard = Keychain(service: UIDevice.targetName!.removeWhitespaces())

    subscript(key: Constants.KeychainKeys) -> String? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }

    subscript(data key: Constants.KeychainKeys) -> Data? {
        get {
            return self[data: key.rawValue]
        }
        set {
            self[data: key.rawValue] = newValue
        }
    }
}
