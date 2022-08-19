//
//  DeeplinkManager.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 18.08.2022.
//

import Foundation
import Combine
import Cleevio

enum DeeplinkScreen {
    case chat(ManagedChat)
    case request
}

enum DeeplinkRequest {
    case openChat(inboxPK: String, senderPK: String)
    case openRequest
}

protocol DeeplinkManagerType {
    var openDeeplink: AnyPublisher<DeeplinkScreen, Never> { get }

    func handleDeeplink(with request: DeeplinkRequest)
}

final class DeeplinkManager: DeeplinkManagerType {
    var openDeeplink: AnyPublisher<DeeplinkScreen, Never> { openDeeplinkSubject.eraseToAnyPublisher() }

    @Inject private var chatRepository: ChatRepositoryType

    private let openDeeplinkSubject = PassthroughSubject<DeeplinkScreen, Never>()
    private let cancelBag = CancelBag()

    func handleDeeplink(with request: DeeplinkRequest) {
        switch request {
        case let .openChat(inbox, sender):
            chatRepository
                .getChat(inboxPK: inbox, senderPK: sender)
                .replaceError(with: nil)
                .filterNil()
                .map { DeeplinkScreen.chat($0) }
                .subscribe(openDeeplinkSubject)
                .store(in: cancelBag)
        case .openRequest:
            openDeeplinkSubject.send(.request)
        }
    }
}
