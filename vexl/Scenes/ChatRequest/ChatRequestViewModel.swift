//
//  ChatRequestViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import Foundation
import Cleevio
import Combine

private typealias OfferAndSenderKeys = (offerKey: OfferKeys, senderPublicKey: String)
private typealias IndexAndConfirmation = (chat: ManagedChat, confirmation: Bool)
private typealias OfferAndMessage = (offer: ManagedOffer, message: MessagePayload)

final class ChatRequestViewModel: ViewModelType, ObservableObject {

    // MARK: - Dependency Bindings

    @Inject var chatService: ChatServiceType
    @Inject var offerService: OfferServiceType
    @Inject var cryptoService: CryptoServiceType
    @Inject var authenticationManager: AuthenticationManagerType
    @Inject var chatManager: ChatManagerType

    // MARK: - Persistence Bindings

    @Fetched(
        sortDescriptors: [ NSSortDescriptor(key: "lastMessageDate", ascending: false) ],
        predicate: NSPredicate(format: "isRequesting == true AND isApproved == false")
    )
    var fetchedRequests: [ManagedChat]

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case acceptTap(chat: ManagedChat)
        case rejectTap(chat: ManagedChat)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var offerRequests: [ChatRequestOfferViewData] = []

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

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

    private var offerAndSenderKeys: [OfferAndSenderKeys] = []
    private let cancelBag: CancelBag = .init()

    init() {
        setupActivity()
        setupActionBindings()
        setupDataBindings()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$isLoading)

        errorIndicator
            .errors
            .asOptional()
            .assign(to: &$error)
    }

    private func setupDataBindings() {
        $fetchedRequests.publisher
            .map(\.objects)
            .map { chats in
                chats.compactMap(ChatRequestOfferViewData.init)
            }
            .assign(to: &$offerRequests)
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
            .compactMap { action -> IndexAndConfirmation? in
                switch action {
                case let .acceptTap(chat):
                    return IndexAndConfirmation(chat: chat, confirmation: true)
                case let .rejectTap(chat):
                    return IndexAndConfirmation(chat: chat, confirmation: false)
                default:
                    return nil
                }
            }
            .flatMap { [chatManager] chat, confirmation in
                chatManager.communicationResponse(chat: chat, confirmation: confirmation)
            }
            .sink()
            .store(in: cancelBag)
    }
}
