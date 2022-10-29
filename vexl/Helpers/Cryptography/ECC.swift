//
//  ECC.swift
//  vexl
//
//  Created by Adam Salih on 24.04.2022.
//

import Foundation

struct ECC {
    static func sign(keys: ECCKeys, message: String) throws -> String {
        guard let privateKey = keys.privateKey else {
            throw CryptographicError.missingPrivateKey
        }
        guard let cSignature = ecdsa_sign(keys.publicKey.ptr, privateKey.ptr, message.ptr, Int32(message.count)) else {
            throw CryptographicError.encryptionError
        }
        let signature = String(cString: cSignature)
        cSignature.deallocate()
        return signature
    }

    static func verify(publicKey: String, message: String, signature: String) -> Bool {
        ecdsa_verify(publicKey.ptr, message.ptr, Int32(message.count), signature.ptr)
    }

    static func encrypt(publicKey: String, secret: String) throws -> String {
        let nsSecret = NSString(string: secret)
        let nsPublicKey = NSString(string: publicKey)
        let secretPtr = UnsafeMutablePointer<CChar>(mutating: nsSecret.utf8String)
        let publicKeyPtr = UnsafeMutablePointer<CChar>(mutating: nsPublicKey.utf8String)
        let cipherPtr = ecies_encrypt(publicKeyPtr, secretPtr)
        guard let cipherPtr = cipherPtr else {
            throw CryptographicError.encryptionError
        }
        let cipher = String(cString: cipherPtr)
        cipherPtr.deallocate()
        return cipher
    }

    static func decrypt(keys: ECCKeys, cipher: String) throws -> String {
        guard let privateKey = keys.privateKey else {
            throw CryptographicError.missingPrivateKey
        }
        let nsCipher = NSString(string: cipher)
        let nsPublicKey = NSString(string: keys.publicKey)
        let nsPrivateKey = NSString(string: privateKey)
        let cipherPtr = UnsafeMutablePointer<CChar>(mutating: nsCipher.utf8String)
        let publicKeyPtr = UnsafeMutablePointer<CChar>(mutating: nsPublicKey.utf8String)
        let privateKeyPtr = UnsafeMutablePointer<CChar>(mutating: nsPrivateKey.utf8String)
        guard let cSecret = ecies_decrypt(publicKeyPtr, privateKeyPtr, cipherPtr) else {
            throw CryptographicError.decryptionError
        }
        let secret = String(cString: cSecret)
        cSecret.deallocate()
        return secret
    }

    var secret: String


    func sign(keys: ECCKeys) throws -> String {
        try Self.sign(keys: keys, message: secret)
    }

    func verify(publicKey: String, message: String) -> Bool {
        Self.verify(publicKey: publicKey, message: message, signature: secret)
    }

    func encrypt(publicKey: String) throws -> String {
        try Self.encrypt(publicKey: publicKey, secret: secret)
    }

    func decrypt(keys: ECCKeys) throws -> String {
        try Self.decrypt(keys: keys, cipher: secret)
    }
}
