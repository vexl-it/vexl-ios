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

    func asymetric_encrypt(publicKey: String, secret: String) throws -> String
    func asymetric_decrypt(cipher: String) throws -> String

    func symetric_encrypt(password: String, secret: String) throws -> String
    func symetric_decrypt(password: String, cipher: String) throws -> String
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

    }

    private var userKeys: ECIESKeys { .init(pubKey: publicKey, privKey: privateKey) }

    init() {
        keychain = .init()
    }

    func asymetric_encrypt(publicKey: String, secret: String) throws -> String {
        var keyPair: KeyPair = .init()
        let nsPublicKey = NSString(string: publicKey)
        keyPair.pemPublicKey = UnsafeMutablePointer<CChar>(mutating: nsPublicKey.utf8String)
        let nsSecret = NSString(string: secret)
        let cipherPtr = ecies_encrypt(keyPair, UnsafeMutablePointer<CChar>(mutating: nsSecret.utf8String))
        guard let cipherPtr = cipherPtr else {
            throw EncryptionError.encryptionError
        }
        let cipher = String(cString: cipherPtr)
        cipherPtr.deallocate()
        return cipher
    }

    func asymetric_decrypt(cipher: String) throws -> String {
        let nsCipher = NSString(string: cipher)
        let secretPtr = ecies_decrypt(userKeys.asKeyPair, UnsafeMutablePointer<CChar>(mutating: nsCipher.utf8String))
        guard let secretPtr = secretPtr else {
            throw EncryptionError.decryptionError
        }
        let secret = String(cString: secretPtr)
        secretPtr.deallocate()
        return secret
    }

    func symetric_encrypt(password: String, secret: String) throws -> String {
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

    func symetric_decrypt(password: String, cipher: String) throws -> String {
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
