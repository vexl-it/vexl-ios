//
//  FacebokUserSignature.swift
//  vexl
//
//  Created by Diego Espinoza on 31/03/22.
//

import Foundation

struct FacebookUserSignature: Decodable {
    var hash: String
    var signature: String
    var challengeVerified: String
}
