//
//  ManagedKeyPair+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation
import KeychainAccess

extension ManagedKeyPair {
    var privateKey: String? {
        get { publicKey.flatMap { Keychain.standard[.privateKey(publicKey: $0)] } }
        set { publicKey.flatMap { Keychain.standard[.privateKey(publicKey: $0)] = newValue } }
    }

    var keys: ECCKeys? {
        guard let pubK = publicKey else {
            return nil
        }
        return ECCKeys(pubKey: pubK, privKey: privateKey)
    }
}
