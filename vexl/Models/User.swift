//
//  User.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

struct User: Codable {
    let userId: Int?
    var username: String
    let avatar: String?
    let publicKey: String

    var facebookId: String?
    var facebookToken: String?

    var avatarImage: Data?
}

struct EditUser: Decodable {
    let username: String
    let avatar: String?
    let publicKey: String
}
