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

    // MARK: - Offer

    func saveOffers(_ offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error>
    func getOffers() -> AnyPublisher<[Offer], Error>

    // MARK: - Inbox and Message cache

    func saveInbox(_ inbox: ChatInbox) throws
    func getInboxes(ofType type: ChatInbox.InboxType) throws -> [ChatInbox]
    func saveInboxMessage(_ message: ParsedChatMessage, inboxKeys: ECCKeys) -> AnyPublisher<Void, Error>
    func getInboxMessages() -> AnyPublisher<[ChatInboxMessage], Error>

    // MARK - Messages

    func saveMessages(_ messages: [ParsedChatMessage]) -> AnyPublisher<Void, Error>
    func getMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func saveRequestMessage(_ message: ParsedChatMessage, inboxPublicKey: String) -> AnyPublisher<Void, Error>
    func getRequestMessages() -> AnyPublisher<[ParsedChatMessage], Error>
    func deleteRequestMessage(withOfferId id: String) -> AnyPublisher<Void, Error>
    func deleteChatMessages(forInbox inboxPublicKey: String, senderPublicKey: String) -> AnyPublisher<Void, Error>
    func getChatMessages(inboxPublicKey: String, receiverInboxKey: String) -> AnyPublisher<[ParsedChatMessage], Error>
}

final class LocalStorageService: LocalStorageServiceType {

    // MARK: - Offer

    func saveOffers(_ offers: [Offer], areCreated: Bool) -> AnyPublisher<Void, Error> {
        Future { promise in
            let storedOffers = offers.map {
                StoredOffer(offer: $0,
                            id: $0.offerId,
                            keys: ECCKeys(pubKey: $0.offerPublicKey, privKey: $0.offerPrivateKey),
                            source: areCreated ? .created : .fetched)
            }

            if areCreated {
                DictionaryDB.saveCreatedOffers(storedOffers)
            } else {
                DictionaryDB.saveFetchedOffers(storedOffers)
            }

            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func getOffers() -> AnyPublisher<[Offer], Error> {
        Future { promise in
            let createdOffers = DictionaryDB.getCreatedOffers()
            let fetchedOffers = DictionaryDB.getFetchedOffers()
            let storedOffers = createdOffers + fetchedOffers
            let offers = Self.convertStoredOffers(storedOffers)
            promise(.success(offers))
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Inbox and Message cache

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

    // MARK - Messages

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
                .filter {
                    $0.inboxKey == inboxPublicKey
                    && $0.senderInboxKey == receiverInboxKey
                    && MessageType.displayableMessages.contains($0.messageType)
                }
            promise(.success(filteredMessages))
        }
        .eraseToAnyPublisher()
    }
    
    func deleteChatMessages(forInbox inboxPublicKey: String, senderPublicKey: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            
        }
        .eraseToAnyPublisher()
    }

    // TODO: - helper method, remove when core data is implemented

    private static func convertStoredOffers(_ storedOffers: [StoredOffer]) -> [Offer] {
        var offers: [Offer] = []
        storedOffers.forEach { item in
            if let storedOffer = Offer(storedOffer: item) {
                offers.append(storedOffer)
            }
        }
        return offers
    }
}
