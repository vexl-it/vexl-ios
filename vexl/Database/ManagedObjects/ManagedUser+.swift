//
//  ManagedUser+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation
import KeychainAccess

extension ManagedUser {
    var signature: String? {
        get {
            guard let localEncryptionKey = Keychain.standard[.localEncryptionKey] else {
                return nil
            }
            return try? encryptedSignature?.aes.decrypt(password: localEncryptionKey)
        }
        set {
            guard let localEncryptionKey = Keychain.standard[.localEncryptionKey] else {
                return
            }
            encryptedSignature = try? newValue?.aes.encrypt(password: localEncryptionKey) }
    }
}
