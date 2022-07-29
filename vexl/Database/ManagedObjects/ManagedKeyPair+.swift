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
        get { try? encryptedPrivateKey?.aes.decrypt(password: Constants.localEncryptionPassowrd) }
        set { encryptedPrivateKey = try? newValue?.aes.encrypt(password: Constants.localEncryptionPassowrd) }
    }

    var keys: ECCKeys? {
        guard let pubK = publicKey else {
            return nil
        }
        return ECCKeys(pubKey: pubK, privKey: privateKey)
    }
}
