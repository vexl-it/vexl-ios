//
//  DictionaryDB.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 02.06.2022.
//

import Foundation

// This is not for production, just to accelerate development. Later we should setup CoreData with proper security

@available(*, deprecated)
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

    static private var storedOffer: [String: [StoredOffer]] = ["created": [], "fetched": []] {
        didSet {
            guard let encodedData = try? encoder.encode(storedOffer) else { return }
            UserDefaults.standard.setValue(encodedData, forKey: "storedOffer")
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

        if let storedOfferData = UserDefaults.standard.data(forKey: "storedOffer"),
           let savedStoredOffer = try? decoder.decode([String: [StoredOffer]].self, from: storedOfferData) {
            storedOffer = savedStoredOffer
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
        self.messages.append(contentsOf: messages)
    }

    static func getMessages() -> [ParsedChatMessage] {
        self.messages
    }

    static func saveRequests(_ request: ParsedChatMessage, inboxPublicKey: String) {
        self.requests.append(request)
    }

    static func getRequests() -> [ParsedChatMessage] {
        self.requests
    }

    static func deleteRequest(with id: String) {
        let newRequests = requests.filter { $0.inboxKey != id }
        requests = newRequests
    }

    static func saveInboxMessages(_ message: ParsedChatMessage, inboxKeys: ECCKeys, receiverInboxPublicKey: String) {
        let inboxIndex = self.inboxMessage.firstIndex(where: {
            $0.inbox.publicKey == inboxKeys.publicKey && $0.receiverInbox == receiverInboxPublicKey
        })

        if let index = inboxIndex {
            let newChatInboxMessage = ChatInboxMessage(inbox: inboxKeys,
                                                       receiverInbox: receiverInboxPublicKey,
                                                       message: message)
            self.inboxMessage[index] = newChatInboxMessage
        } else {
            self.inboxMessage.append(.init(inbox: inboxKeys, receiverInbox: receiverInboxPublicKey, message: message))
        }
    }

    static func getInboxMessages() -> [ChatInboxMessage] {
        self.inboxMessage
    }

    static func getCreatedOffers() -> [StoredOffer] {
        storedOffer["created"] ?? []
    }

    static func getFetchedOffers() -> [StoredOffer] {
        storedOffer["fetched"] ?? []
    }

    static func saveCreatedOffers(_ offers: [StoredOffer]) {
        var content = storedOffer["created"] ?? []
        content.append(contentsOf: offers)
        storedOffer["created"] = content
    }

    static func saveFetchedOffers(_ offers: [StoredOffer]) {
        storedOffer["fetched"] = offers
    }
}
