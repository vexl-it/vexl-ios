//
//  OfferKeys.swift
//  vexl
//
//  Created by Diego Espinoza on 29/06/22.
//

import Foundation

struct OfferKeys {
    let id: String
    let publicKey: String
    let privateKey: String?

    var keys: ECCKeys {
        ECCKeys(pubKey: publicKey, privKey: privateKey)
    }
}
