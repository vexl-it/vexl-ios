//
//  ChatRequestViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import Foundation
import Cleevio
import Combine

private typealias OfferKeyAndSenderKey = (offerKey: UserOfferKeys.OfferKey, senderPublicKey: String)
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
        case confirmationTap(id: String, confirmation: Bool)
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

    private var offerAndSenderKeys: [OfferKeyAndSenderKey] = []
    private var storedOfferKeys: [UserOfferKeys.OfferKey] = []
    private var offerAndMessage: [String: OfferAndMessage] = [:]
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
        let communicationRequests = offerService
            .getStoredOfferKeys()
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, keys in
                owner.storedOfferKeys = keys
            })
            .flatMap { owner, _ -> AnyPublisher<[ParsedChatMessage], Never> in
                owner.chatService
                    .getRequestMessages()
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }

        let getOffers = communicationRequests
            .withUnretained(self)
            .flatMap { owner, parsedMessages -> AnyPublisher<Void, Never> in
                owner.offerService
                    .getUserOffers(offerIds: owner.storedOfferKeys.map { $0.id })
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { Offer.createOffers(from: $0, withKey: owner.userSecurity.userKeys) }
                    .handleEvents(receiveOutput: { offers in
                        for message in parsedMessages {
                            if let offer = offers.first(where: { $0.offerPublicKey == message.inboxKey }),
                               let key = owner.storedOfferKeys.first(where: { $0.id == offer.offerId }) {
                                owner.offerAndMessage[key.id] = OfferAndMessage(offer: offer, message: message)
                            }
                        }
                    })
                    .asVoid()
                    .eraseToAnyPublisher()
            }

        getOffers
            .withUnretained(self)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, _ in

                var offerRequestViewData: [ChatRequestOfferViewData] = []
                var offerAndSender: [OfferKeyAndSenderKey] = []

                owner.offerAndMessage.forEach { key, value in
                    if let offerKey = owner.storedOfferKeys.first(where: { key == $0.id }) {
                        let senderPublicKey = value.message.senderInboxKey
                        let viewData = ChatRequestOfferViewData(contactName: Constants.randomName,
                                                                contactFriendLevel: value.offer.friendLevel.label,
                                                                requestText: value.message.text ?? "",
                                                                friends: [],
                                                                offer: .init(offer: value.offer, isRequested: false))
                        offerRequestViewData.append(viewData)
                        offerAndSender.append(OfferKeyAndSenderKey(offerKey: offerKey, senderPublicKey: senderPublicKey))
                    }
                }

                owner.offerRequests = offerRequestViewData
                owner.offerAndSenderKeys = offerAndSender
            })
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

    private func communicationRequest(index: Int, isConfirmed: Bool) -> AnyPublisher<IndexAndConfirmation, Never> {
        let keys = offerAndSenderKeys[index]
        let generateSignature = validateSignature(forOfferIndex: index, confirmation: isConfirmed, withInboxKey: keys.offerKey.key)
            .track(activity: primaryActivity)
            .materialize()
            .compactMap(\.value)

        return generateSignature
            .flatMapLatest(with: self) { owner, signature -> AnyPublisher<IndexAndConfirmation, Never> in
                let message = ParsedChatMessage
                    .communicationConfirmation(isConfirmed: isConfirmed,
                                               inboxPublicKey: keys.offerKey.publicKey)

                return owner.chatService
                    .communicationConfirmation(confirmation: isConfirmed,
                                               message: message,
                                               inboxPublicKey: keys.offerKey.publicKey,
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

    private func removeConfirmedRequest(atIndex index: Int) {
        var offers = offerRequests
        offers.remove(at: index)
        offerRequests = offers
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
}
