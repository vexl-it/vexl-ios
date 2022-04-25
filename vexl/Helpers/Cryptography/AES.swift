//
//  AES.swift
//  vexl
//
//  Created by Adam Salih on 24.04.2022.
//

import Foundation

struct AES {
    static func encrypt(password: String, secret: String) throws -> String {
        let nsSecret = NSString(string: secret)
        let nsPassword = NSString(string: password)
        let secretPtr = UnsafeMutablePointer<CChar>(mutating: nsSecret.utf8String)
        let passwordPtr = UnsafeMutablePointer<CChar>(mutating: nsPassword.utf8String)
        let cipherPtr = aes_encrypt(passwordPtr, secretPtr)
        guard let cipherPtr = cipherPtr else {
            throw CryptographicError.encryptionError
        }
        let cipher = String(cString: cipherPtr)
        cipherPtr.deallocate()
        return cipher
    }

    static func decrypt(password: String, cipher: String) throws -> String {
        let nsCipher = NSString(string: cipher)
        let nsPassword = NSString(string: password)
        let cipherPtr = UnsafeMutablePointer<CChar>(mutating: nsCipher.utf8String)
        let passwordPtr = UnsafeMutablePointer<CChar>(mutating: nsPassword.utf8String)
        let secretPtr = aes_decrypt(passwordPtr, cipherPtr)
        guard let secretPtr = secretPtr else {
            throw CryptographicError.decryptionError
        }
        let secret = String(cString: secretPtr)
        secretPtr.deallocate()
        return secret
    }

    var secret: String

    func encrypt(password: String) throws -> String {
        try Self.encrypt(password: password, secret: secret)
    }

    func decrypt(password: String) throws -> String {
        try Self.decrypt(password: password, cipher: secret)
    }
}
