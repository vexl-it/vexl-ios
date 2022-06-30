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
private typealias IndexAndConfirmation = (index: Int, confirmation: Bool)
private typealias OfferAndMessage = (offer: Offer, message: ParsedChatMessage)

final class ChatRequestViewModel: ViewModelType, ObservableObject {

    @Inject var userSecurity: UserSecurityType
    @Inject var chatService: ChatServiceType
    @Inject var offerService: OfferServiceType
    @Inject var cryptoService: CryptoServiceType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case acceptTap(id: String)
        case rejectTap(id: String)
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
        offerService
            .getStoredOfferkeys(fromSource: .all)
            .track(activity: primaryActivity)
            .withUnretained(self)
            .flatMap { owner, keys in
                owner.prepareRequestedMessages(storedOfferKeys: keys)
            }
            .sink()
            .store(in: cancelBag)
    }

    private func setupActionBindings() {

        let action = action
            .share()

        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        let request = action
            .withUnretained(self)
            .compactMap { owner, action -> IndexAndConfirmation? in
                switch action {
                case let .acceptTap(id):
                    if let index = owner.offerRequests.firstIndex(where: { $0.id == id }) {
                        return IndexAndConfirmation(index: index, confirmation: true)
                    }
                    return nil
                case let .rejectTap(id):
                    if let index = owner.offerRequests.firstIndex(where: { $0.id == id }) {
                        return IndexAndConfirmation(index: index, confirmation: false)
                    }
                    return nil
                default:
                    return nil
                }
            }

        request
            .flatMapLatest(with: self) { owner, indexAndConfirmation in
                owner.communicationRequest(index: indexAndConfirmation.index, isConfirmed: indexAndConfirmation.confirmation)
            }
            .withUnretained(self)
            .sink { owner, indexAndConfirmation in
                owner.removeConfirmedRequest(atIndex: indexAndConfirmation.index)
            }
            .store(in: cancelBag)
    }

    // MARK: - Helper methods for presenting the request that are pending of approval/rejection

    private func prepareRequestedMessages(storedOfferKeys: [OfferKeys]) -> AnyPublisher<Void, Never> {
        chatService
            .getStoredRequestMessages()
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .flatMapLatest(with: self) { owner, parsedMessages -> AnyPublisher<(offers: [Offer], messages: [ParsedChatMessage]), Never> in
                owner.fetchUserOffers(offerKeys: storedOfferKeys)
                    .map { (offers: $0, messages: parsedMessages) }
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, offersAndMessages in
                owner.saveRequestedOffers(offersAndMessages.offers,
                                          offerKeys: storedOfferKeys,
                                          parsedMessages: offersAndMessages.messages)
            })
            .asVoid()
            .eraseToAnyPublisher()
    }

    private func fetchUserOffers(offerKeys: [OfferKeys]) -> AnyPublisher<[Offer], Never> {
        offerService
            .getUserOffers(offerIds: offerKeys.map(\.id))
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)
            .map { Offer.createOffers(from: $0, withKey: self.userSecurity.userKeys, source: .fetched) }
            .eraseToAnyPublisher()
    }

    private func saveRequestedOffers(_ offers: [Offer], offerKeys: [OfferKeys], parsedMessages: [ParsedChatMessage]) {

        var offerRequestViewData: [ChatRequestOfferViewData] = []
        var offerAndSender: [OfferAndSenderKeys] = []

        for message in parsedMessages {
            if let offer = offers.first(where: { $0.offerPublicKey == message.inboxKey }),
               let key = offerKeys.first(where: { $0.id == offer.offerId }) {

                let senderPublicKey = message.senderInboxKey
                let viewData = ChatRequestOfferViewData(contactName: Constants.randomName,
                                                        contactFriendLevel: offer.friendLevel.label,
                                                        requestText: message.text ?? "",
                                                        friends: [],
                                                        offer: .init(offer: offer, isRequested: false))

                offerRequestViewData.append(viewData)
                offerAndSender.append(OfferAndSenderKeys(offerKey: key, senderPublicKey: senderPublicKey))
            }
        }

        offerRequests = offerRequestViewData
        offerAndSenderKeys = offerAndSender
    }

    // MARK: - Helper methods for sending the confirmation request to the BE

    private func communicationRequest(index: Int, isConfirmed: Bool) -> AnyPublisher<IndexAndConfirmation, Never> {
        let keys = offerAndSenderKeys[index]
        let generateSignature = validateSignature(forOfferIndex: index, confirmation: isConfirmed, withInboxKey: keys.offerKey.keys)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)

        return generateSignature
            .flatMapLatest(with: self) { owner, signature -> AnyPublisher<IndexAndConfirmation, Never> in
                let message = ParsedChatMessage
                    .communicationConfirmation(isConfirmed: isConfirmed,
                                               inboxPublicKey: keys.offerKey.publicKey,
                                               senderPublicKey: keys.senderPublicKey)

                return owner.chatService
                    .communicationConfirmation(confirmation: isConfirmed,
                                               message: message,
                                               inboxKeys: keys.offerKey.keys,
                                               requesterPublicKey: keys.senderPublicKey,
                                               signature: signature)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map {
                        IndexAndConfirmation(index: index,
                                             confirmation: isConfirmed)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func validateSignature(forOfferIndex index: Int,
                                   confirmation: Bool,
                                   withInboxKey offerKeys: ECCKeys) -> AnyPublisher<String, Error> {
        chatService.requestChallenge(publicKey: offerKeys.publicKey)
            .flatMapLatest(with: self) { owner, challenge in
                owner.cryptoService.signECDSA(keys: offerKeys,
                                              message: challenge.challenge)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func removeConfirmedRequest(atIndex index: Int) {
        var offers = offerRequests
        offers.remove(at: index)
        offerRequests = offers
    }
}
