//
//  ChatError.swift
//  vexl
//
//  Created by Diego Espinoza on 5/06/22.
//

import Foundation

enum InboxError: Error {
    case noLocalInboxes
    case inboxSyncFailed
    case inboxesSyncFailed
}
