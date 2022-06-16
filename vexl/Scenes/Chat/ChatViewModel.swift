//
//  ChatViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import Foundation
import Cleevio

final class ChatViewModel: ViewModelType, ObservableObject {

    enum Modal {
        case none
        case offer
        case friends
        case delete
        case deleteConfirmation
        case block
        case blockConfirmation
        case identityRevealRequest
        case identityRevealConfirmation
    }

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case chatActionTap(action: ChatAction)
        case messageSend
        case cameraTap
        case dismissModal
        case deleteTap
        case deleteConfirmedTap
        case blockTap
        case blockConfirmedTap
        case revealRequestTap
        case revealConfirmedTap
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
    let friends: [ChatCommonFriendViewData] = [.stub, .stub, .stub]
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
        setupModalBindings()
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
                owner.messages.appendMessage(.init(category: .text(text: owner.currentMessage), isContact: false))
                owner.currentMessage = ""
            }
            .store(in: cancelBag)
    }

    private func setupModalBindings() {

        let action = action
            .share()

        let chatAction = action
            .compactMap { action -> ChatAction? in
                if case let .chatActionTap(chatAction) = action { return chatAction }
                return nil
            }
            .share()

        chatAction
            .filter { $0 == .showOffer }
            .map { _ -> Modal in .offer }
            .assign(to: &$modal)

        chatAction
            .filter { $0 == .commonFriends }
            .map { _ -> Modal in .friends }
            .assign(to: &$modal)

        chatAction
            .filter { $0 == .deleteChat }
            .map { _ -> Modal in .delete }
            .assign(to: &$modal)

        chatAction
            .filter { $0 == .blockUser }
            .map { _ -> Modal in .block }
            .assign(to: &$modal)

        chatAction
            .filter { $0 == .revealIdentity }
            .map { _ -> Modal in .identityRevealRequest }
            .assign(to: &$modal)

        action
            .filter { $0 == .dismissModal }
            .withUnretained(self)
            .map { _ -> Modal in .none }
            .assign(to: &$modal)

        action
            .filter { $0 == .deleteTap }
            .map { _ -> Modal in .deleteConfirmation }
            .assign(to: &$modal)

        action
            .filter { $0 == .blockTap }
            .map { _ -> Modal in .blockConfirmation }
            .assign(to: &$modal)

        action
            .filter { $0 == .deleteConfirmedTap }
            .map { _ -> Modal in .none }
            .assign(to: &$modal)

        action
            .filter { $0 == .blockConfirmedTap }
            .map { _ -> Modal in .none }
            .assign(to: &$modal)

        action
            .filter { $0 == .revealConfirmedTap }
            .map { _ -> Modal in .identityRevealConfirmation }
            .assign(to: &$modal)
    }
}
