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
    case groupInput(String)
}

enum DeeplinkRequest {
    case openChat(inboxPK: String, senderPK: String)
    case openRequest
    case openGroup(id: String)
    case openInbox
}

protocol DeeplinkManagerType {
    var openDeeplink: AnyPublisher<DeeplinkScreen, Never> { get }
    var goToInboxTab: AnyPublisher<Void, Never> { get }
    var canOpenDeepLink: Bool { get }
    var shouldGoToInboxOnStartup: Bool { get }

    func handleDeeplink(with request: DeeplinkRequest)
    func handleDeeplink(withURL url: URL)
    func cleanState()
    func setCanOpenDeeplink(to value: Bool)
}

final class DeeplinkManager: DeeplinkManagerType {
    var openDeeplink: AnyPublisher<DeeplinkScreen, Never> { openDeeplinkSubject.filterNil().eraseToAnyPublisher() }
    var goToInboxTab: AnyPublisher<Void, Never> { goToInboxTabSubject.eraseToAnyPublisher() }
    var canOpenDeepLink = true
    var shouldGoToInboxOnStartup = false

    @Inject private var chatRepository: ChatRepositoryType

    private let goToInboxTabSubject = PassthroughSubject<Void, Never>()
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
        case let .openGroup(id):
            openDeeplinkSubject.send(.groupInput(id))
        case .openInbox:
            shouldGoToInboxOnStartup = true
            goToInboxTabSubject.send()
        }
    }

    func handleDeeplink(withURL url: URL) {
        guard let code = url.valueOf("code") else { return }
        handleDeeplink(with: .openGroup(id: code))
    }

    func cleanState() {
        openDeeplinkSubject.send(nil)
        shouldGoToInboxOnStartup = false
    }

    func setCanOpenDeeplink(to value: Bool) {
        canOpenDeepLink = value
    }
}
