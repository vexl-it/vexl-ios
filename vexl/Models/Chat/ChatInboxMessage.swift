//
//  ChatConversation.swift
//  vexl
//
//  Created by Diego Espinoza on 22/06/22.
//

import Foundation

struct ChatInboxMessage: Codable {
    let inbox: ECCKeys
    let receiverInbox: String
    let message: ParsedChatMessage
}
