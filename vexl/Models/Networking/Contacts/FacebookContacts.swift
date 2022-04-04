//
//  FacebookContact.swift
//  vexl
//
//  Created by Diego Espinoza on 4/04/22.
//

import Foundation

struct FacebookContacts: Decodable {

    var facebookUser: FacebookUser

    struct FacebookUser: Decodable {
        var id: String
        var name: String
        var profilePicture: ProfilePicture?
        var friends: [FacebookUser]
    }

    // swiftlint:disable nesting
    struct ProfilePicture: Decodable {

        var data: PictureData?

        struct PictureData: Decodable {
            var url: String?
        }
    }
}
