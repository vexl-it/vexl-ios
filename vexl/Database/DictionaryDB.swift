//
//  DictionaryDB.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Foundation

// This is not for production, just to accelerate development. Later we should setup CoreData with proper security

final class DictionaryDB {
    static private var inboxes: [String: [OfferInbox]] = ["created": [], "requested": []] {
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

    static private var requests: [ParsedChatMessage] = [] {
        didSet {
            guard let encodedData = try? JSONEncoder().encode(messages) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "requests")
        }
    }

    static func setupDatabase() {
        if let inboxesData = UserDefaults.standard.data(forKey: "inboxes"),
           let savedInboxes = try? JSONDecoder().decode([String: [OfferInbox]].self, from: inboxesData) {
            inboxes = savedInboxes
        }

        if let messagesData = UserDefaults.standard.data(forKey: "messages"),
           let savedMessages = try? JSONDecoder().decode([ParsedChatMessage].self, from: messagesData) {
            messages = savedMessages
        }

        if let requestsData = UserDefaults.standard.data(forKey: "requests"),
           let savedRequests = try? JSONDecoder().decode([ParsedChatMessage].self, from: requestsData) {
            requests = savedRequests
        }
    }

    static func saveCreatedInbox(_ inbox: OfferInbox) {
        var content = inboxes["created"] ?? []
        content.append(inbox)
        inboxes["created"] = content
    }

    static func saveRequestedInbox(_ inbox: OfferInbox) {
        var content = inboxes["requested"] ?? []
        content.append(inbox)
        inboxes["requested"] = content
    }

    static func getCreatedInboxes() -> [OfferInbox] {
        inboxes["created"] ?? []
    }

    static func getRequestedInboxes() -> [OfferInbox] {
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

    static func saveRequests(_ requests: [ParsedChatMessage]) {
        var content = self.requests
        content.append(contentsOf: requests)
        self.requests = content
    }

    static func getRequests() -> [ParsedChatMessage] {
        self.requests
    }
}
