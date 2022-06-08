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
    func saveInbox(_ inbox: UserInbox) throws
    func getInboxes(ofType type: UserInbox.InboxType) throws -> [UserInbox]
    func saveMessages(_ messages: [ChatMessage]) -> AnyPublisher<Void, Error>
    func getMessages() -> AnyPublisher<[ParsedChatMessage], Error>
}

final class LocalStorageService: LocalStorageServiceType {
    func saveInbox(_ inbox: UserInbox) throws {
        switch inbox.type {
        case .created:
            DictionaryDB.saveCreatedInbox(inbox)
        case .requested:
            DictionaryDB.saveRequestedInbox(inbox)
        }
    }

    func getInboxes(ofType type: UserInbox.InboxType) throws -> [UserInbox] {
        switch type {
        case .created:
            return DictionaryDB.getCreatedInboxes()
        case .requested:
            return DictionaryDB.getRequestedInboxes()
        }
    }

    func saveMessages(_ messages: [ChatMessage]) -> AnyPublisher<Void, Error> {
        Future { promise in
            var parsedMessages: [ParsedChatMessage] = []
            for message in messages {
                if let parsedMessage = ParsedChatMessage(chatMessage: message) {
                    parsedMessages.append(parsedMessage)
                }
            }
            DictionaryDB.saveMessages(parsedMessages)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func getMessages() -> AnyPublisher<[ParsedChatMessage], Error> {
        Future { promise in
            promise(.success((DictionaryDB.getMessages())))
        }
        .eraseToAnyPublisher()
    }
}
