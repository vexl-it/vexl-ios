//
//  Encryptable+.swift
//  vexl
//
//  Created by Adam Salih on 11.07.2022.
//

import Foundation

protocol Encryptable {
    var asString: String { get }

    var sha: SHA { get }
    var ecc: ECC { get }
    var aes: AES { get }
    var hmac: HMAC { get }
}

extension Encryptable {
    var sha: SHA { SHA(secret: asString) }
    var ecc: ECC { ECC(secret: asString) }
    var aes: AES { AES(secret: asString) }
    var hmac: HMAC { HMAC(secret: asString) }
}
