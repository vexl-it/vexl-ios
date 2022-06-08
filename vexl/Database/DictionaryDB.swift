//
//  DictionaryDB.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Foundation

// This is not for production, just to accelerate development. Later we should setup CoreData with proper security

final class DictionaryDB {
    static private var inboxes: [String: [UserInbox]] = ["created": [], "requested": []] {
        didSet {
            guard let encodedData = try? JSONEncoder().encode(inboxes) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "inboxes")
        }
    }

    static private var messages: [ParsedChatMessage] = [] {
        didSet {
            guard let encodedData = try? JSONEncoder().encode(messages) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "messages")
        }
    }

    static func setupDatabase() {
        guard let inboxesData = UserDefaults.standard.data(forKey: "inboxes"),
              let savedInboxes = try? JSONDecoder().decode([String: [UserInbox]].self, from: inboxesData) else { return }

        inboxes = savedInboxes
    }

    static func saveCreatedInbox(_ inbox: UserInbox) {
        var content = inboxes["created"] ?? []
        content.append(inbox)
        inboxes["created"] = content
    }

    static func saveRequestedInbox(_ inbox: UserInbox) {
        var content = inboxes["requested"] ?? []
        content.append(inbox)
        inboxes["requested"] = content
    }

    static func getCreatedInboxes() -> [UserInbox] {
        inboxes["created"] ?? []
    }

    static func getRequestedInboxes() -> [UserInbox] {
        inboxes["requested"] ?? []
    }

    static func saveMessages(_ messages: [ParsedChatMessage]) {
        var content = self.messages
        content.append(contentsOf: messages)
        self.messages = content
    }

    static func getMessages() -> [ParsedChatMessage] {
        self.messages
    }
}
