//
//  EncryptionService.swift
//  vexl
//
//  Created by Adam Salih on 19.04.2022.
//

import Foundation
import KeychainAccess

enum EncryptionError: Error {
    case encryptionError
    case decryptionError
    case missingPrivateKey
    case verificationError
}

protocol CryptoServiceType {
    func hashSHA(data: String) throws -> String

    func hashHMAC(password: String, message: String) throws -> String
    func verifyHMAC(password: String, message: String, digest: String) -> Bool

    func signECDSA(keys: ECKeys, message: String) throws -> String
    func verifyECDSA(publicKey: String, message: String, signature: String) -> Bool

    func encryptECIES(publicKey: String, secret: String) throws -> String
    func decryptECIES(keys: ECKeys, cipher: String) throws -> String

    func encryptAES(password: String, secret: String) throws -> String
    func decryptAES(password: String, cipher: String) throws -> String
}

class CryptoService: CryptoServiceType {

    static func hashSHA(data: String) throws -> String {
        try CryptoService().hashSHA(data: data)
    }

    static func hashHMAC(password: String, message: String) throws -> String {
        try CryptoService().hashHMAC(password: password, message: message)
    }

    static func verifyHMAC(password: String, message: String, digest: String) -> Bool {
        CryptoService().verifyHMAC(password: password, message: message, digest: digest)
    }

    static func signECDSA(keys: ECKeys, message: String) throws -> String {
        try CryptoService().signECDSA(keys: keys, message: message)
    }

    static func verifyECDSA(publicKey: String, message: String, signature: String) -> Bool {
        CryptoService().verifyECDSA(publicKey: publicKey, message: message, signature: signature)
    }

    static func encryptECIES(publicKey: String, secret: String) throws -> String {
        try CryptoService().encryptECIES(publicKey: publicKey, secret: secret)
    }

    static func decryptECIES(keys: ECKeys, cipher: String) throws -> String {
        try CryptoService().decryptECIES(keys: keys, cipher: cipher)
    }

    static func encryptAES(password: String, secret: String) throws -> String {
        try CryptoService().encryptAES(password: password, secret: secret)
    }

    static func decryptAES(password: String, cipher: String) throws -> String {
        try CryptoService().decryptAES(password: password, cipher: cipher)
    }


    func hashSHA(data: String) throws -> String {
        guard let cDigest = sha256_hash(data.ptr, Int32(data.count)) else {
            throw EncryptionError.encryptionError
        }
        let digest = String(cString: cDigest)
        cDigest.deallocate()
        return digest
    }

    func hashHMAC(password: String, message: String) throws -> String {
        guard let cDigest = hmac_digest(password.ptr, message.ptr) else {
            throw EncryptionError.encryptionError
        }
        let digest = String(cString: cDigest)
        cDigest.deallocate()
        return digest
    }

    func verifyHMAC(password: String, message: String, digest: String) -> Bool {
        hmac_verify(password.ptr, message.ptr, digest.ptr)
    }

    func signECDSA(keys: ECKeys, message: String) throws -> String {
        guard let privateKey = keys.privateKey else {
            throw EncryptionError.missingPrivateKey
        }
        guard let cSignature = ecdsa_sign(keys.publicKey.ptr, privateKey.ptr, message.ptr, Int32(message.count)) else {
            throw EncryptionError.encryptionError
        }
        let signature = String(cString: cSignature)
        cSignature.deallocate()
        return signature
    }

    func verifyECDSA(publicKey: String, message: String, signature: String) -> Bool {
        ecdsa_verify(publicKey.ptr, message.ptr, Int32(message.count), signature.ptr)
    }

    func encryptECIES(publicKey: String, secret: String) throws -> String {
        let cipherPtr = ecies_encrypt(publicKey.ptr, secret.ptr)
        guard let cipherPtr = cipherPtr else {
            throw EncryptionError.encryptionError
        }
        let cipher = String(cString: cipherPtr)
        cipherPtr.deallocate()
        return cipher
    }

    func decryptECIES(keys: ECKeys, cipher: String) throws -> String {
        guard let privateKey = keys.privateKey else {
            throw EncryptionError.missingPrivateKey
        }
        guard let cSecret = ecies_decrypt(keys.publicKey.ptr, privateKey.ptr, cipher.ptr) else {
            throw EncryptionError.decryptionError
        }
        let secret = String(cString: cSecret)
        cSecret.deallocate()
        return secret
    }

    func encryptAES(password: String, secret: String) throws -> String {
        let nsSecret = NSString(string: secret)
        let nsPassword = NSString(string: password)
        let secretPtr = UnsafeMutablePointer<CChar>(mutating: nsSecret.utf8String)
        let passwordPtr = UnsafeMutablePointer<CChar>(mutating: nsPassword.utf8String)
        let cipherPtr = aes_encrypt(passwordPtr, secretPtr)
        guard let cipherPtr = cipherPtr else {
            throw EncryptionError.encryptionError
        }
        let cipher = String(cString: cipherPtr)
        cipherPtr.deallocate()
        return cipher
    }

    func decryptAES(password: String, cipher: String) throws -> String {
        let nsCipher = NSString(string: cipher)
        let nsPassword = NSString(string: password)
        let cipherPtr = UnsafeMutablePointer<CChar>(mutating: nsCipher.utf8String)
        let passwordPtr = UnsafeMutablePointer<CChar>(mutating: nsPassword.utf8String)
        let secretPtr = aes_decrypt(passwordPtr, cipherPtr)
        guard let secretPtr = secretPtr else {
            throw EncryptionError.decryptionError
        }
        let secret = String(cString: secretPtr)
        secretPtr.deallocate()
        return secret
    }
}
