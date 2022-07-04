//
//  StoredChatUser.swift
//  vexl
//
//  Created by Diego Espinoza on 4/07/22.
//

import Foundation

// TODO: - delete this when the CoreData ChatUser is created

struct StoredChatUser: Codable {
    let inboxPublicKey: String
    let senderPublicKey: String
    let username: String
    let avatar: String?
}
