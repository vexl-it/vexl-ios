//
//  ChatConversation.swift
//  vexl
//
//  Created by Diego Espinoza on 22/06/22.
//

import Foundation

struct ChatInboxMessage: Codable {
    let inbox: ECCKeys
    let contactInbox: String
    let message: MessagePayload
}
