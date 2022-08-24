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
    var canOpenDeepLink: Bool { get }

    func handleDeeplink(with request: DeeplinkRequest)
    func cleanState()
    func setCanOpenDeeplink(to value: Bool)
}

final class DeeplinkManager: DeeplinkManagerType {
    var openDeeplink: AnyPublisher<DeeplinkScreen, Never> { openDeeplinkSubject.filterNil().eraseToAnyPublisher() }
    var canOpenDeepLink = true

    @Inject private var chatRepository: ChatRepositoryType

    private let openDeeplinkSubject = CurrentValueSubject<DeeplinkScreen?, Never>(nil)
    private let cancelBag = CancelBag()

    func handleDeeplink(with request: DeeplinkRequest) {
        switch request {
        case let .openChat(inbox, sender):
            chatRepository
                .getChat(inboxPK: inbox, senderPK: sender)
                .replaceError(with: nil)
                .filterNil()
                .map { DeeplinkScreen.chat($0) }
                .sink(receiveValue: { [openDeeplinkSubject] deeplink in
                    openDeeplinkSubject.send(deeplink)
                })
                .store(in: cancelBag)
        case .openRequest:
            openDeeplinkSubject.send(.request)
        }
    }

    func cleanState() {
        openDeeplinkSubject.send(nil)
    }

    func setCanOpenDeeplink(to value: Bool) {
        canOpenDeepLink = value
    }
}
