//
//  ChatMessageViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import Foundation
import Cleevio

final class ChatMessageViewModel: ViewModelType, ObservableObject {

    enum Modal {
        case none
        case offer
    }

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case chatActionTap(action: ChatMessageAction)
        case messageSend
        case cameraTap
        case dismissModal
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var currentMessage: String = ""

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var presentedModal = Modal.none

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var username: String {
        "Keichi"
    }

    var messages: [ChatMessageGroup] = ChatMessageGroup.stub
    let offerType: OfferType = .buy

    private let cancelBag: CancelBag = .init()

    init() {
        setupActionBindings()
    }

    private func setupActionBindings() {

        let action = action
            .share()

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        action
            .filter { $0 == .messageSend }
            .withUnretained(self)
            .sink { owner, _ in
                owner.messages.appendMessage(.init(text: owner.currentMessage, isContact: false))
                owner.currentMessage = ""
            }
            .store(in: cancelBag)

        action
            .filter { $0 == .dismissModal }
            .withUnretained(self)
            .map { _ -> Modal in .none }
            .assign(to: &$presentedModal)

        action
            .compactMap { action -> ChatMessageAction? in
                if case let .chatActionTap(chatAction) = action { return chatAction }
                return nil
            }
            .filter { $0 == .showOffer }
            .map { _ -> Modal in .offer }
            .assign(to: &$presentedModal)
    }
}

extension Array where Element == ChatMessageGroup {
    mutating func appendMessage(_ message: ChatMessageGroup.Message) {
        if let lastGroup = self.last {
            var updatedGroup = lastGroup
            updatedGroup.addMessage(message)
            self[self.count - 1] = updatedGroup
        } else {
            let newGroup = ChatMessageGroup(date: Date(),
                                            messages: [message])
            self.append(newGroup)
        }
    }
}
