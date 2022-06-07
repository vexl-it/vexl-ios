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
        case friends
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
    @Published var modal = Modal.none

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

    let username: String = "Keichi"
    let avatar: UIImage? = nil
    let friends: [ChatMessageCommonFriendViewData] = [.stub, .stub, .stub]
    var messages: [ChatMessageGroup] = ChatMessageGroup.stub
    let offerType: OfferType = .buy

    var offerLabel: String {
        offerType == .buy ? L.marketplaceDetailUserBuy("") : L.marketplaceDetailUserSell("")
    }

    var isModalPresented: Bool {
        modal != .none
    }

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
            .assign(to: &$modal)

        action
            .compactMap { action -> ChatMessageAction? in
                if case let .chatActionTap(chatAction) = action { return chatAction }
                return nil
            }
            .filter { $0 == .showOffer }
            .map { _ -> Modal in .offer }
            .assign(to: &$modal)

        action
            .compactMap { action -> ChatMessageAction? in
                if case let .chatActionTap(chatAction) = action { return chatAction }
                return nil
            }
            .filter { $0 == .commonFriends }
            .map { _ -> Modal in .friends }
            .assign(to: &$modal)
    }
}
