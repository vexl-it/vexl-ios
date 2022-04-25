//
//  HMAC.swift
//  vexl
//
//  Created by Adam Salih on 24.04.2022.
//

import Foundation

struct HMAC {
    static func hash(password: String, message: String) throws -> String {
        guard let cDigest = hmac_digest(password.ptr, message.ptr) else {
            throw CryptographicError.encryptionError
        }
        let digest = String(cString: cDigest)
        cDigest.deallocate()
        return digest
    }

    static func verify(password: String, message: String, digest: String) -> Bool {
        hmac_verify(password.ptr, message.ptr, digest.ptr)
    }

    var secret: String

    func hash(password: String) throws -> String {
        try Self.hash(password: password, message: secret)
    }

    func verify(password: String, message: String) -> Bool {
        Self.verify(password: password, message: message, digest: secret)
    }
}
