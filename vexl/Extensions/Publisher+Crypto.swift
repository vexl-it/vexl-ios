//
//  Publisher+Crypto.swift
//  vexl
//
//  Created by Adam Salih on 22.04.2022.
//

import Combine

extension Publisher where Output == String {
    func hashSHA() throws -> Publishers.TryMap<Self, String> {
        tryMap { data in
            try data.sha.hash()
        }
    }

    func hashHMAC(password: String) -> Publishers.TryMap<Self, ChecksumHMAC> {
        tryMap { message in
            let digest = try message.hmac.hash(password: password)
            return (message: message, digest: digest)
        }
    }

    func signECDSA(keys: ECCKeys) -> Publishers.TryMap<Self, Signature> {
        tryMap { message in
            let signature = try message.ecc.sign(keys: keys)
            return (message: message, digest: signature)
        }
    }

    func encryptECIES(publicKey: String) -> Publishers.TryMap<Self, String> {
        tryMap { secret in
            try secret.ecc.encrypt(publicKey: publicKey)
        }
    }

    func decryptECIES(keys: ECCKeys) -> Publishers.TryMap<Self, String> {
        tryMap { cipher in
            try cipher.ecc.decrypt(keys: keys)
        }
    }

    func encryptAES(password: String) -> Publishers.TryMap<Self, String> {
        tryMap { secret in
            try secret.aes.encrypt(password: password)
        }
    }

    func decryptAES(password: String) -> Publishers.TryMap<Self, String> {
        tryMap { cipher in
            try cipher.aes.decrypt(password: password)
        }
    }
}

typealias Signature = (message: String, digest: String)

extension Publisher where Output == Signature {
    func verifyECDSA(publicKey: String) -> Publishers.TryMap<Self, Void> {
        tryMap { signature in
            let verified = signature.digest.ecc.verify(publicKey: publicKey, message: signature.message)
            if !verified {
                throw CryptographicError.verificationError
            }
        }
    }
}

typealias ChecksumHMAC = (message: String, digest: String)

extension Publisher where Output == ChecksumHMAC {
    func verifyHMAC(password: String) -> Publishers.TryMap<Self, Void> {
        tryMap { checksum in
            let verified = checksum.digest.hmac.verify(password: password, message: checksum.message)
            if !verified {
                throw CryptographicError.verificationError
            }
        }
    }
}
