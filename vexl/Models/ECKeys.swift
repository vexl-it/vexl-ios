//
//  ECIESKeys.swift
//  vexl
//
//  Created by Adam Salih on 19.04.2022.
//

import Foundation

struct ECKeys {
    var publicKey: String
    var privateKey: String?

    init(curve: Curve = Constants.elipticCurve) {
        let keyPair = generate_key_pair(curve)
        self.init(keyPair: keyPair)
        KeyPair_free(keyPair)
    }

    init(keyPair: KeyPair) {
        publicKey = String(cString: keyPair.pemPublicKey)
        privateKey = String(cString: keyPair.pemPrivateKey)
    }

    init(pubKey: String, privKey: String? = nil) {
        publicKey = pubKey
        privateKey = privKey
    }
}
