//
//  DictionaryDB.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Foundation

// This is not for production, just to accelerate development. Later we should setup CoreData with proper security

final class DictionaryDB {

    static private let encoder = Constants.jsonEncoder
    static private let decoder = Constants.jsonDecoder

    static private var inboxes: [String: [OfferInbox]] = ["created": [], "requested": []] {
        didSet {
            guard let encodedData = try? encoder.encode(inboxes) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "inboxes")
        }
    }

    static private var messages: [ParsedChatMessage] = [] {
        didSet {
            guard let encodedData = try? encoder.encode(messages) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "messages")
        }
    }

    static private var requests: [String: ParsedChatMessage] = [:] {
        didSet {
            guard let encodedData = try? encoder.encode(requests) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "requests")
        }
    }

    static private var displayMessage: [String: ParsedChatMessage] = [:] {
        didSet {
            guard let encodedData = try? encoder.encode(displayMessage) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "displayMessage")
        }
    }

    static func setupDatabase() {
        if let inboxesData = UserDefaults.standard.data(forKey: "inboxes"),
           let savedInboxes = try? decoder.decode([String: [OfferInbox]].self, from: inboxesData) {
            inboxes = savedInboxes
        }

        if let messagesData = UserDefaults.standard.data(forKey: "messages"),
           let savedMessages = try? decoder.decode([ParsedChatMessage].self, from: messagesData) {
            messages = savedMessages
        }

        if let requestsData = UserDefaults.standard.data(forKey: "requests"),
           let savedRequests = try? decoder.decode([String: ParsedChatMessage].self, from: requestsData) {
            requests = savedRequests
        }

        if let displayData = UserDefaults.standard.data(forKey: "displayMessage"),
           let savedDisplayMessages = try? decoder.decode([String: ParsedChatMessage].self, from: displayData) {
            displayMessage = savedDisplayMessages
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

    static func saveRequests(_ request: ParsedChatMessage, inboxPublicKey: String) {
        var content = self.requests
        content[inboxPublicKey] = request
        self.requests = content
    }

    static func getRequests() -> [String: ParsedChatMessage] {
        self.requests
    }

    static func saveDisplayMessages(_ request: ParsedChatMessage, inboxPublicKey: String) {
        var content = self.displayMessage
        content[inboxPublicKey] = request
        self.requests = content
    }

    static func getDisplayMessages() -> [String: ParsedChatMessage] {
        self.displayMessage
    }
}
