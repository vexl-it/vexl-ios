//
//  ContactUser.swift
//  vexl
//
//  Created by Diego Espinoza on 2/04/22.
//

import Foundation

struct ContactUser: Decodable {
    var id: Int
    var publicKey: String
    var hash: String
}
