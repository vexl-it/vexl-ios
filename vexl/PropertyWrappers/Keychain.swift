//
//  Keychain.swift
//  vexl
//
//  Created by Adam Salih on 11.07.2022.
//

import Foundation
import KeychainAccess

@propertyWrapper
struct KeychainStore {
    let key: Constants.KeychainKeys

    var wrappedValue: String? {
        get { Keychain.standard[key] }
        set { Keychain.standard[key] = newValue }
    }
}
