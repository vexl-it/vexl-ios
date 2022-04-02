//
//  ChallengeValidation.swift
//  vexl
//
//  Created by Diego Espinoza on 1/04/22.
//

import Foundation

struct ChallengeValidation: Codable {
    var hash: String
    var signature: String
    var challengeVerified: Bool
}
