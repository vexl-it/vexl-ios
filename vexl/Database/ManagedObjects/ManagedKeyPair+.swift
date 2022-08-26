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
        get {
            guard let localEncryptionKey = Keychain.standard[.localEncryptionKey] else {
                return nil
            }
            return try? encryptedPrivateKey?.aes.decrypt(password: localEncryptionKey)
        }
        set {
            guard let localEncryptionKey = Keychain.standard[.localEncryptionKey] else {
                return
            }
            encryptedPrivateKey = try? newValue?.aes.encrypt(password: localEncryptionKey) }
    }

    var keys: ECCKeys? {
        guard let pubK = publicKey else {
            return nil
        }
        return ECCKeys(pubKey: pubK, privKey: privateKey)
    }

    var offer: ManagedOffer? {
        receiversOffer ?? userOffer
    }
}
