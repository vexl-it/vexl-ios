//
//  FacebokUserSignature.swift
//  vexl
//
//  Created by Diego Espinoza on 31/03/22.
//

import Foundation

struct FacebookUserSignature: Codable {
    var hash: String
    var signature: String
    var challengeVerified: String
}
