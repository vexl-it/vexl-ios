//
//  ContactsImported.swift
//  vexl
//
//  Created by Diego Espinoza on 2/04/22.
//

import Foundation

struct ContactsImported: Decodable {
    var imported: Bool
    var message: String

    static var none = ContactsImported(imported: true, message: "")
}
