//
//  ECIESKeys.swift
//  vexl
//
//  Created by Adam Salih on 19.04.2022.
//

import Foundation

struct ECIESKeys {
    var publicKey: String
    private var securedPrivateKey: String?
    var privateKey: String? {
        // TODO: Discuss with the team the possibility of encrypting the private key in memory
        return securedPrivateKey
    }

    init(curve: Curve) {
        let keyPair = generate_key_pair(curve)
        self.init(keyPair: keyPair)
        KeyPair_free(keyPair)
    }

    init(keyPair: KeyPair) {
        publicKey = String(cString: keyPair.pemPublicKey)
        securedPrivateKey = String(cString: keyPair.pemPrivateKey)
    }

    init(pubKey: String, privKey: String? = nil) {
        publicKey = pubKey
        securedPrivateKey = privKey
    }

    var asKeyPair: KeyPair {
        var keyPair: KeyPair = .init()
        let nsPubKey = NSString(string: publicKey)
        let pubKeyPtr = UnsafeMutablePointer<CChar>(mutating: nsPubKey.utf8String)
        keyPair.pemPublicKey = pubKeyPtr
        if let privateKey = privateKey {
            let nsPrivKey = NSString(string: privateKey)
            let privKeyPtr = UnsafeMutablePointer<CChar>(mutating: nsPrivKey.utf8String)
            keyPair.pemPrivateKey = privKeyPtr
        }
        return keyPair
    }
}
