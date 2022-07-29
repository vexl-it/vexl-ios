//
//  ChatMessageGroup.swift
//  vexl
//
//  Created by Diego Espinoza on 2/06/22.
//

import Foundation

/// Struct used for grouping the conversation elements of each user
/// the grouping will be done using the date

struct ChatConversationSection: Identifiable, Hashable {

    let id = "UUID"
    let date: Date
    var messages: [ChatConversationItem]
}

extension ChatConversationSection {
    static var stub: [ChatConversationSection] {
        []
    }
}
