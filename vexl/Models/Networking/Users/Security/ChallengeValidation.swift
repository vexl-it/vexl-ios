//
//  ChallengeValidation.swift
//  vexl
//
//  Created by Diego Espinoza on 1/04/22.
//

import Foundation

struct ChallengeValidation: Decodable {
    var hash: String
    var signature: String
    var challengeVerified: Bool
}
