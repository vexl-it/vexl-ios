//
//  Keychain+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
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

    subscript<T: Codable>(codable key: Constants.KeychainKeys) -> T? {
        get {
            guard let keychainData = self[data: key.rawValue],
                  let object = try? Constants.jsonDecoder.decode(T.self, from: keychainData) else {
                return nil
            }
            return object
        }
        set {
            guard let newValue = newValue else {
                self[data: key] = nil
                return
            }
            guard let jsonData = try? Constants.jsonEncoder.encode(newValue) else {
                return
            }
            self[data: key.rawValue] = jsonData
        }
    }
}
