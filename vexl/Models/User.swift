//
//  User.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import Foundation

struct User: Decodable {
    let userId: Int
    let username: String
    let avatar: String?
    let publicKey: String

    var avatarURL: String? {
        guard let avatar = avatar else {
            return nil
        }
        return "\(Constants.API.userBaseURLString)/\(avatar)"
    }
}
