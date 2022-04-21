//
//  EncryptionService.swift
//  vexl
//
//  Created by Adam Salih on 19.04.2022.
//

import Foundation
import KeychainAccess

// swiftlint:disable private_over_fileprivate
fileprivate enum EncryptionServiceKeychain: String {
    case privateKey
    case publicKey
}

enum EncryptionError: Error {
    case encryptionError
    case decryptionError
}

protocol EncryptionManagerType {
    var publicKey: String { get }

    func hash(data: String) -> String

    func hmac(password: String, message: String) -> String
    func hmacVerify(password: String, message: String, digest: String) -> Bool

    func signECDSA(publicKey: String, privateKey: String, message: String) -> String
    func verifyECDSA(publicKey: String, message: String, signature: String) -> Bool

    func encryptECIES(publicKey: String, secret: String) throws -> String
    func decryptECIES(publicKey: String, privateKey: String, cipher: String) throws -> String

    func encryptAES(password: String, secret: String) throws -> String
    func decryptAES(password: String, cipher: String) throws -> String
}

class EncryptionManager: EncryptionManagerType {
    var publicKey: String {
        if let pubKey = keychain[EncryptionServiceKeychain.publicKey.rawValue] {
            return pubKey
        }
        let keys = ECIESKeys(curve: curve)
        keychain[EncryptionServiceKeychain.privateKey.rawValue] = keys.privateKey
        keychain[EncryptionServiceKeychain.publicKey.rawValue] = keys.publicKey
        return keys.publicKey
    }

    private let keychain: Keychain = .init(service: Bundle.main.bundleIdentifier!)

    private let curve: Curve = .init(rawValue: UInt32(8)) // Using the secp224k1 curve

    private var privateKey: String {
        if let privKey = keychain[EncryptionServiceKeychain.privateKey.rawValue] {
            return privKey
        }
        let keys = ECIESKeys(curve: curve)
        keychain[EncryptionServiceKeychain.privateKey.rawValue] = keys.privateKey
        keychain[EncryptionServiceKeychain.publicKey.rawValue] = keys.publicKey
        return keys.privateKey!
    }

    private var userKeys: ECIESKeys { .init(pubKey: publicKey, privKey: privateKey) }

    func hash(data: String) -> String {
        String(cString: sha256_hash(data.ptr, Int32(data.count)))
    }

    func hmac(password: String, message: String) -> String {
        String(cString: hmac_digest(password.ptr, message.ptr))
    }

    func hmacVerify(password: String, message: String, digest: String) -> Bool {
        hmac_verify(password.ptr, message.ptr, digest.ptr)
    }

    func signECDSA(publicKey: String, privateKey: String, message: String) -> String {
        String(cString: ecdsa_sign(publicKey.ptr, privateKey.ptr, message.ptr, Int32(message.count)))
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

    func decryptECIES(publicKey: String, privateKey: String, cipher: String) throws -> String {
        let secretPtr = ecies_decrypt(publicKey.ptr, privateKey.ptr, cipher.ptr)
        guard let secretPtr = secretPtr else {
            throw EncryptionError.decryptionError
        }
        let secret = String(cString: secretPtr)
        secretPtr.deallocate()
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
