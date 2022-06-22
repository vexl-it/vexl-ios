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

    static private var inboxes: [String: [ChatInbox]] = ["created": [], "requested": []] {
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

    static private var requests: [ParsedChatMessage] = [] {
        didSet {
            guard let encodedData = try? encoder.encode(requests) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "requests")
        }
    }

    static private var inboxMessage: [ChatInboxMessage] = [] {
        didSet {
            guard let encodedData = try? encoder.encode(inboxMessage) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "inboxMessages")
        }
    }

    static func setupDatabase() {
        if let inboxesData = UserDefaults.standard.data(forKey: "inboxes"),
           let savedInboxes = try? decoder.decode([String: [ChatInbox]].self, from: inboxesData) {
            inboxes = savedInboxes
        }

        if let messagesData = UserDefaults.standard.data(forKey: "messages"),
           let savedMessages = try? decoder.decode([ParsedChatMessage].self, from: messagesData) {
            messages = savedMessages
        }

        if let requestsData = UserDefaults.standard.data(forKey: "requests"),
           let savedRequests = try? decoder.decode([ParsedChatMessage].self, from: requestsData) {
            requests = savedRequests
        }

        if let inboxMessagesData = UserDefaults.standard.data(forKey: "inboxMessages"),
           let savedInboxMessages = try? decoder.decode([ChatInboxMessage].self, from: inboxMessagesData) {
            inboxMessage = savedInboxMessages
        }
    }

    static func saveCreatedInbox(_ inbox: ChatInbox) {
        var content = inboxes["created"] ?? []
        content.append(inbox)
        inboxes["created"] = content
    }

    static func saveRequestedInbox(_ inbox: ChatInbox) {
        var content = inboxes["requested"] ?? []
        content.append(inbox)
        inboxes["requested"] = content
    }

    static func getCreatedInboxes() -> [ChatInbox] {
        inboxes["created"] ?? []
    }

    static func getRequestedInboxes() -> [ChatInbox] {
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
        content.append(request)
        self.requests = content
    }

    static func getRequests() -> [ParsedChatMessage] {
        self.requests
    }

    static func deleteRequest(with id: String) {
        let newRequests = requests.filter { $0.inboxKey != id }
        requests = newRequests
    }

    static func saveInboxMessages(_ message: ParsedChatMessage, inboxKeys: ECCKeys, receiverInboxPublicKey: String) {
        var content = self.inboxMessage
        content.append(.init(inbox: inboxKeys, receiverInbox: receiverInboxPublicKey, message: message))
        self.inboxMessage = content
    }

    static func updateInboxMessage(_ message: ParsedChatMessage, inboxPublicKeys: ECCKeys, receiverInboxPublicKey: String) {
        guard let index = self.inboxMessage.firstIndex(where: {
            $0.inbox.publicKey == inboxPublicKeys.publicKey && $0.receiverInbox == receiverInboxPublicKey
        }) else {
            return
        }

        let newChatInboxMessage = ChatInboxMessage(inbox: inboxPublicKeys,
                                                   receiverInbox: receiverInboxPublicKey,
                                                   message: message)
        self.inboxMessage[index] = newChatInboxMessage
    }

    static func getInboxMessages() -> [ChatInboxMessage] {
        self.inboxMessage
    }
}
