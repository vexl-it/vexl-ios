//
//  Publisher+Crypto.swift
//  vexl
//
//  Created by Adam Salih on 22.04.2022.
//

import Combine

typealias Signature = (message: String, digest: String)

extension Publisher where Output == Signature {
    func verifyECDSA(publicKey: String) -> Publishers.TryMap<Self, Void> {
        tryMap { signature in
            let verified = CryptoService.verifyECDSA(publicKey: publicKey, message: signature.message, signature: signature.digest)
            if !verified {
                throw EncryptionError.verificationError
            }
        }
    }
}

typealias ChecksumHMAC = (message: String, digest: String)

extension Publisher where Output == ChecksumHMAC {
    func verifyHMAC(password: String) -> Publishers.TryMap<Self, Void> {
        tryMap { checksum in
            let verified = CryptoService.verifyHMAC(password: password, message: checksum.message, digest: checksum.digest)
            if !verified {
                throw EncryptionError.verificationError
            }
        }
    }
}

extension Publisher where Output == String {
    func hashSHA() throws -> Publishers.TryMap<Self, String> {
        tryMap { data in
            try CryptoService.hashSHA(data: data)
        }
    }

    func hashHMAC(password: String) -> Publishers.TryMap<Self, ChecksumHMAC> {
        tryMap { message in
            let digest = try CryptoService.hashHMAC(password: password, message: message)
            return (message: message, digest: digest)
        }
    }

    func signECDSA(keys: ECKeys) -> Publishers.TryMap<Self, Signature> {
        tryMap { message in
            let signature = try CryptoService.signECDSA(keys: keys, message: message)
            return (message: message, digest: signature)
        }
    }

    func encryptECIES(publicKey: String) -> Publishers.TryMap<Self, String> {
        tryMap { secret in
            try CryptoService.encryptECIES(publicKey: publicKey, secret: secret)
        }
    }

    func decryptECIES(keys: ECKeys) -> Publishers.TryMap<Self, String> {
        tryMap { cipher in
            try CryptoService.decryptECIES(keys: keys, cipher: cipher)
        }
    }

    func encryptAES(password: String) -> Publishers.TryMap<Self, String> {
        tryMap { secret in
            try CryptoService.encryptAES(password: password, secret: secret)
        }
    }

    func decryptAES(password: String) -> Publishers.TryMap<Self, String> {
        tryMap { cipher in
            try CryptoService.decryptAES(password: password, cipher: cipher)
        }
    }
}
