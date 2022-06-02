//
//  LocalStorageService.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Combine
import Foundation

enum LocalStorageError: Error {
    case saveFailed
    case readFailed
}

protocol LocalStorageServiceType {
    func saveInbox(_ inbox: Inbox) throws
    func getInboxes(ofType type: Inbox.InboxType) throws -> [Inbox]
}

final class LocalStorageService: LocalStorageServiceType {
    func saveInbox(_ inbox: Inbox) throws {
        switch inbox.type {
        case .created:
            DictionaryDB.saveCreatedInbox(inbox)
        case .requested:
            DictionaryDB.saveRequestedInbox(inbox)
        }
    }

    func getInboxes(ofType type: Inbox.InboxType) throws -> [Inbox] {
        switch type {
        case .created:
            return DictionaryDB.getCreatedInboxes()
        case .requested:
            return DictionaryDB.getRequestedInboxes()
        }
    }
}
