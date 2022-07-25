//
//  ManagedUser+.swift
//  vexl
//
//  Created by Adam Salih on 03.07.2022.
//

import Foundation

extension ManagedUser {
    var signature: String? {
        get { try? encryptedSignature?.aes.decrypt(password: Constants.localEncryptionPassowrd) }
        set { encryptedSignature = try? newValue?.aes.encrypt(password: Constants.localEncryptionPassowrd) }
    }
}
