//
//  ChatService.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Combine

protocol ChatServiceType {
    func createInbox(offerPublicKey: String, pushToken: String) -> AnyPublisher<Void, Error>
    func request(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error>
    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<[ChatMessage], Error>
    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error>

    func saveFetchedMessages(_ messages: [ChatMessage]) -> AnyPublisher<Void, Error>
}

final class ChatService: BaseService, ChatServiceType {
    @Inject private var cryptoService: CryptoServiceType
    @Inject private var localStorageService: LocalStorageServiceType

    func createInbox(offerPublicKey: String, pushToken: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [localStorageService] promise in
            do {
                try localStorageService.saveInbox(UserInbox(publicKey: offerPublicKey, type: .created))
                promise(.success(()))
            } catch {
                promise(.failure(LocalStorageError.saveFailed))
            }
        }
        .flatMapLatest(with: self) { owner, _ in
            owner.request(endpoint: ChatRouter.createInbox(offerPublicKey: offerPublicKey, pushToken: pushToken))
        }
        .eraseToAnyPublisher()
    }

    func request(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [localStorageService] promise in
            do {
                try localStorageService.saveInbox(UserInbox(publicKey: inboxPublicKey, type: .requested))
                promise(.success(()))
            } catch {
                promise(.failure(LocalStorageError.saveFailed))
            }
        }
        .flatMapLatest(with: self) { owner, _ in
            owner.cryptoService
                .encryptECIES(publicKey: inboxPublicKey, secret: message)
        }
        .flatMapLatest(with: self) { owner, encryptedMessage in
            owner.request(endpoint: ChatRouter.request(inboxPublicKey: inboxPublicKey, message: encryptedMessage))
        }
        .eraseToAnyPublisher()
    }

    func requestChallenge(publicKey: String) -> AnyPublisher<ChatChallenge, Error> {
        request(type: ChatChallenge.self, endpoint: ChatRouter.requestChallenge(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    func pullInboxMessages(publicKey: String, signature: String) -> AnyPublisher<[ChatMessage], Error> {
        request(type: [ChatMessage].self, endpoint: ChatRouter.pullChat(publicKey: publicKey, signature: signature))
            .eraseToAnyPublisher()
    }

    func deleteInboxMessages(publicKey: String) -> AnyPublisher<Void, Error> {
        request(endpoint: ChatRouter.deleteChat(publicKey: publicKey))
            .eraseToAnyPublisher()
    }

    func saveFetchedMessages(_ messages: [ChatMessage]) -> AnyPublisher<Void, Error> {
        localStorageService.saveMessages(messages)
    }
}
