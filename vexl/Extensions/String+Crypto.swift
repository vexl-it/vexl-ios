//
//  String+Crypto.swift
//  vexl
//
//  Created by Adam Salih on 24.04.2022.
//

import Foundation

extension String {
    var sha: SHA { SHA(secret: self) }

    var ecc: ECC { ECC(secret: self) }

    var aes: AES { AES(secret: self) }

    var hmac: HMAC { HMAC(secret: self) }
}
