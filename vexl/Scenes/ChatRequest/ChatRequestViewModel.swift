//
//  ChatRequestViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import Foundation
import Cleevio
import Combine

private typealias OfferAndMessage = (offer: Offer, message: ParsedChatMessage)
private typealias OfferIdsAndMessages = (ids: [String], messages: [ParsedChatMessage])

final class ChatRequestViewModel: ViewModelType, ObservableObject {

    @Inject var userSecurity: UserSecurityType
    @Inject var chatService: ChatServiceType
    @Inject var offerService: OfferServiceType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
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
        let offerIds = offerService
            .getAllStoredOfferIds()
            .setFailureType(to: Error.self)
            .flatMapLatest(with: self) { owner, ids -> AnyPublisher<OfferIdsAndMessages, Error> in
                owner.chatService
                    .getRequestMessages()
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { OfferIdsAndMessages(ids: ids, messages: $0) }
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

        let getOffers = offerIds
            .flatMapLatest(with: self) { owner, offerIdsAndMessages -> AnyPublisher<[OfferAndMessage], Error> in
                owner.offerService
                    .getUserOffers(offerIds: offerIdsAndMessages.ids)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { encryptedOffers -> [OfferAndMessage] in
                        var offerAndMessages: [OfferAndMessage] = []
                        let decryptedOffers = Offer.createOffers(from: encryptedOffers, withKey: owner.userSecurity.userKeys)
                        for message in offerIdsAndMessages.messages {
                            if let decryptedOffer = decryptedOffers.first(where: { $0.offerPublicKey == message.inboxKey }) {
                                offerAndMessages.append(OfferAndMessage(offer: decryptedOffer, message: message))
                            }
                        }
                        return offerAndMessages
                    }
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

        getOffers
            .withUnretained(self)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, offerAndMessages in
                owner.offerRequests = offerAndMessages.map { offer, message -> ChatRequestOfferViewData in
                    let offerDetailViewData = OfferDetailViewData(offer: offer, isRequested: false)
                    return ChatRequestOfferViewData(contactName: "Random name generator",
                                                    contactFriendLevel: offer.friendLevelString,
                                                    requestText: message.text ?? "",
                                                    friends: [],
                                                    offer: offerDetailViewData)
                }
            })
            .store(in: cancelBag)
    }

    private func setupActionBindings() {
        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
