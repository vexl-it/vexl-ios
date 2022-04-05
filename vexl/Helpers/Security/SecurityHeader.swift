//
//  SecurityHeader.swift
//  vexl
//
//  Created by Diego Espinoza on 24/03/22.
//

import Foundation

struct SecurityHeader {

    var hash: String
    var publicKey: String
    var signature: String

    let header: [Header]

    init(hash: String, publicKey: String, signature: String) {
        self.hash = hash
        self.publicKey = publicKey
        self.signature = signature
        self.header = [
            Header(key: "hash", value: hash),
            Header(key: "public-key", value: publicKey),
            Header(key: "signature", value: signature)
        ]
    }
}
