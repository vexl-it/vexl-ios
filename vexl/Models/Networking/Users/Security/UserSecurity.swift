//
//  UserValidation.swift
//  vexl
//
//  Created by Diego Espinoza on 31/03/22.
//

import Foundation

struct UserSecurity {
    var keys: ECCKeys?
    var signature: String?
    var hash: String?

    var facebookHash: String?
    var facebookSignature: String?
}
