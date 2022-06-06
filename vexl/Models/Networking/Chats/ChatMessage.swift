//
//  ChatMessage.swift
//  vexl
//
//  Created by Diego Espinoza on 3/06/22.
//

import Foundation

struct ChatMessage: Decodable {
    let senderPublicKey: String
    let message: String
}
