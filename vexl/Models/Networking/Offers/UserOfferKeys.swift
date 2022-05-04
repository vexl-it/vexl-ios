//
//  UserOfferKeys.swift
//  vexl
//
//  Created by Diego Espinoza on 2/05/22.
//

import Foundation

// TODO: - Temporal storage in UserDefault for OfferKeys

struct UserOfferKeys: Codable {

    var keys: [OfferKey]

    struct OfferKey: Codable {
        let id: String
        let privateKey: String?
        let publicKey: String
    }
}
