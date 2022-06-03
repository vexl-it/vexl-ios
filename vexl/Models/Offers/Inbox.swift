//
//  Inbox.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Foundation

struct Inbox: Codable {
    enum InboxType: String, Codable {
        case created
        case requested
    }

    let publicKey: String
    let type: InboxType
}
