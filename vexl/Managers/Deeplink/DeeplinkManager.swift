//
//  DeeplinkManager.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 18.08.2022.
//

import Foundation
import Combine

enum DeeplinkType {
    case openChat
    case openInbox
    case openRequest

    var tab: Tab {
        switch self {
        default:
            return .chat
        }
    }
}

protocol DeeplinkManagerType {
    var openDeeplink: AnyPublisher<DeeplinkType, Never> { get }

    func handleDeeplink(with type: DeeplinkType)
}

final class DeeplinkManager: DeeplinkManagerType {
    var openDeeplink: AnyPublisher<DeeplinkType, Never> { openDeeplinkSubject.eraseToAnyPublisher() }

    private let openDeeplinkSubject = PassthroughSubject<DeeplinkType, Never>()

    func handleDeeplink(with type: DeeplinkType) {
        openDeeplinkSubject.send(type)
    }
}
