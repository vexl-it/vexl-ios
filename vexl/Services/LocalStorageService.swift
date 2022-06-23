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
    func saveOffer(id: String, type: OfferType, key: ECCKeys) -> AnyPublisher<Void, Error>
    func getOffersIds(forType offerType: OfferType) -> AnyPublisher<[String], Never>
    func getAllOffersIds() -> AnyPublisher<[String], Never>
    func getOfferKeys() -> AnyPublisher<[UserOfferKeys.OfferKey], Error>
    func saveInbox(_ inbox: ChatInbox) throws
    func getInboxes(ofType type: ChatInbox.InboxType) throws -> [ChatInbox]
    func saveMessages(_ messages: [ParsedChatMessage]) -> AnyPublisher<Void, Error>
    func getMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func saveRequestMessage(_ message: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error>
    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func deleteRequestMessage(withOfferId id: String) -> AnyPublisher<Void, Error>
    func saveInboxMessage(_ message: ParsedChatMessage, inboxKeys: ECCKeys) -> AnyPublisher<Void, Error>
    func getInboxMessages() -> AnyPublisher<[ChatInboxMessage], Error>
    func getChatMessages(inboxPublicKey: String, receiverInboxKey: String) -> AnyPublisher<[ParsedChatMessage], Error>
}

final class LocalStorageService: LocalStorageServiceType {

    func saveOffer(id: String, type: OfferType, key: ECCKeys) -> AnyPublisher<Void, Error> {
        Future { promise in
            let storedOfferKeys: UserOfferKeys? = UserDefaults.standard.codable(forKey: .storedOfferKeys)
            var currentOfferKeys = storedOfferKeys ?? .init(keys: [])
            currentOfferKeys.keys.append(.init(id: id,
                                               privateKey: key.privateKey,
                                               publicKey: key.publicKey,
                                               type: type.rawValue))
            UserDefaults.standard.set(value: currentOfferKeys, forKey: .storedOfferKeys)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func getOffersIds(forType offerType: OfferType) -> AnyPublisher<[String], Never> {
        Future { promise in
            let storedOfferKeys: UserOfferKeys? = UserDefaults.standard.codable(forKey: .storedOfferKeys)
            let ids = storedOfferKeys?.keys
                .filter { $0.offerType == offerType }
                .map { $0.id }
            promise(.success(ids ?? []))
        }
        .eraseToAnyPublisher()
    }

    func getAllOffersIds() -> AnyPublisher<[String], Never> {
        Future { promise in
            let storedOfferKeys: UserOfferKeys? = UserDefaults.standard.codable(forKey: .storedOfferKeys)
            let ids = storedOfferKeys?.keys
                .map { $0.id }
            promise(.success(ids ?? []))
        }
        .eraseToAnyPublisher()
    }

    func getOfferKeys() -> AnyPublisher<[UserOfferKeys.OfferKey], Error> {
        Future { promise in
            let storedOfferKeys: UserOfferKeys? = UserDefaults.standard.codable(forKey: .storedOfferKeys)
            let offerKey = storedOfferKeys?.keys
            promise(.success(offerKey ?? []))
        }
        .eraseToAnyPublisher()
    }

    func saveInbox(_ inbox: ChatInbox) throws {
        switch inbox.type {
        case .created:
            DictionaryDB.saveCreatedInbox(inbox)
        case .requested:
            DictionaryDB.saveRequestedInbox(inbox)
        }
    }

    func getInboxes(ofType type: ChatInbox.InboxType) throws -> [ChatInbox] {
        switch type {
        case .created:
            return DictionaryDB.getCreatedInboxes()
        case .requested:
            return DictionaryDB.getRequestedInboxes()
        }
    }

    func saveMessages(_ messages: [ParsedChatMessage]) -> AnyPublisher<Void, Error> {
        Future { promise in
            DictionaryDB.saveMessages(messages)
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

    func saveRequestMessage(_ messages: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DictionaryDB.saveRequests(messages, inboxPublicKey: inboxPublicKey)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error> {
        Future { promise in
            promise(.success((DictionaryDB.getRequests())))
        }
        .eraseToAnyPublisher()
    }

    func saveInboxMessage(_ message: ParsedChatMessage, inboxKeys: ECCKeys) -> AnyPublisher<Void, Error> {
        Future { promise in
            DictionaryDB.saveInboxMessages(message, inboxKeys: inboxKeys, receiverInboxPublicKey: message.senderInboxKey)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func getInboxMessages() -> AnyPublisher<[ChatInboxMessage], Error> {
        Future { promise in
            promise(.success(DictionaryDB.getInboxMessages()))
        }
        .eraseToAnyPublisher()
    }

    func deleteRequestMessage(withOfferId id: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DictionaryDB.deleteRequest(with: id)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func getChatMessages(inboxPublicKey: String, receiverInboxKey: String) -> AnyPublisher<[ParsedChatMessage], Error> {
        Future { promise in
            let messages = DictionaryDB.getMessages()
            let filteredMessages = messages
                .filter { $0.inboxKey == inboxPublicKey && $0.senderInboxKey == receiverInboxKey }
                .filter { MessageType.displayableMessages.contains($0.messageType) }
            promise(.success(filteredMessages))
        }
        .eraseToAnyPublisher()
    }
}
