//
//  DictionaryDB.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Foundation

final class DictionaryDB {
    static private var inboxes: [String: [Inbox]] = ["created": [], "requested": []] {
        didSet {
            guard let encodedData = try? JSONEncoder().encode(inboxes) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "inboxes")
        }
    }

    static func setupDatabase() {
        guard let inboxesData = UserDefaults.standard.data(forKey: "inboxes"),
              let savedInboxes = try? JSONDecoder().decode([String: [Inbox]].self, from: inboxesData) else { return }

        inboxes = savedInboxes
    }

    static func saveCreatedInbox(_ inbox: Inbox) {
        var content = inboxes["created"] ?? []
        content.append(inbox)
        inboxes["created"] = content
    }

    static func saveRequestedInbox(_ inbox: Inbox) {
        var content = inboxes["requested"] ?? []
        content.append(inbox)
        inboxes["requested"] = content
    }

    static func getCreatedInboxes() -> [Inbox] {
        inboxes["created"] ?? []
    }

    static func getRequestedInboxes() -> [Inbox] {
        inboxes["requested"] ?? []
    }
}
