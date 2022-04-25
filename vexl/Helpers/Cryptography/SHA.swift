//
//  SHA.swift
//  vexl
//
//  Created by Adam Salih on 24.04.2022.
//

import Foundation

struct SHA {
    static func hash(data: String) throws -> String {
        guard let cDigest = sha256_hash(data.ptr, Int32(data.count)) else {
            throw CryptographicError.encryptionError
        }
        let digest = String(cString: cDigest)
        cDigest.deallocate()
        return digest
    }

    var secret: String

    func hash() throws -> String {
        try Self.hash(data: secret)
    }
}
