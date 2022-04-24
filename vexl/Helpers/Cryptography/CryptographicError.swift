//
//  Error.swift
//  vexl
//
//  Created by Adam Salih on 24.04.2022.
//

import Foundation

enum CryptographicError: Error {
    case encryptionError
    case decryptionError
    case missingPrivateKey
    case verificationError
}
