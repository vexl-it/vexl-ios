//
//  CommonFriends.swift
//  vexl
//
//  Created by Adam Salih on 19.07.2022.
//

import Foundation

// MARK: - CommonFirends
struct CommonFriends: Codable {
    let commonContacts: [CommonContact]

    var asDictionary: [String: [String]] {
        commonContacts.reduce([:]) { dict, contact in
            var dict = dict
            dict[contact.publicKey] = contact.common.hashes
            return dict
        }
    }
}

// MARK: - CommonContact
struct CommonContact: Codable {
    let publicKey: String
    let common: Common
}

// MARK: - Common
struct Common: Codable {
    let hashes: [String]
}
