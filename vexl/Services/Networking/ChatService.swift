//
//  ChatService.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 01.06.2022.
//

import Foundation
import Combine

protocol ChatServiceType {
    func request(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error>
}

final class ChatService: BaseService, ChatServiceType {
    @Inject private var cryptoService: CryptoServiceType

    func request(inboxPublicKey: String, message: String) -> AnyPublisher<Void, Error> {
        cryptoService
            .encryptECIES(publicKey: inboxPublicKey, secret: message)
            .flatMapLatest(with: self) { owner, encryptedMessage in
                owner.request(endpoint: ChatRouter.request(inboxPublicKey: inboxPublicKey, message: encryptedMessage))
            }
            .eraseToAnyPublisher()
    }
}
