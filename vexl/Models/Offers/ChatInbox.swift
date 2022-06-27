//
//  Inbox.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Foundation

struct ChatInbox: Codable {
    enum InboxType: String, Codable {
        case created
        case requested
    }

    let key: ECCKeys
    let type: InboxType

    var publicKey: String {
        key.publicKey
    }

    var privateKey: String? {
        key.privateKey
    }

    init(publicKey: String, type: InboxType) {
        self.key = ECCKeys(pubKey: publicKey, privKey: nil)
        self.type = type
    }

    init(key: ECCKeys, type: InboxType) {
        self.key = key
        self.type = type
    }
}
