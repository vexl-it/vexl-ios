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
private typealias OfferAndSenderKey = (offerPublicKey: String, senderPublicKey: String)
private typealias OfferSenderAndViewData = (keys: OfferAndSenderKey, viewData: ChatRequestOfferViewData)
private typealias KeyAndSignature = (keys: OfferAndSenderKey, signature: String)

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
        case declineTap(id: String)
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

    private var offerAndSenderKeys: [OfferAndSenderKey] = []
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
                            if let decryptedOffer = decryptedOffers.first(where: { $0.offerPublicKey == message.from }) {
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
                let offerRequests = offerAndMessages.map { offer, message -> OfferSenderAndViewData in
                    let offerDetailViewData = OfferDetailViewData(offer: offer, isRequested: false)
                    let keys = OfferAndSenderKey(offerPublicKey: offer.offerPublicKey, senderPublicKey: message.key)
                    let viewData = ChatRequestOfferViewData(contactName: Constants.randomName,
                                                            contactFriendLevel: offer.friendLevel.label,
                                                            requestText: message.text ?? "",
                                                            friends: [],
                                                            offer: offerDetailViewData)
                    return (keys: keys, viewData: viewData)
                }
                owner.offerRequests = offerRequests.map { $0.viewData }
                owner.offerAndSenderKeys = offerRequests.map { $0.keys }
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

        action
            .withUnretained(self)
            .compactMap { owner, action -> Int? in
                if case let .acceptTap(id) = action,
                   let offerIndex = owner.offerRequests.firstIndex(where: { $0.offer.id == id }) {
                    return offerIndex
                }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, index in
                owner.validateSignature(forOfferIndex: index)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .withUnretained(self)
            .flatMap { owner, keyAndSignature in
                owner.chatService
                    .requestConfirmation(confirmation: true,
                                         message: "",
                                         inboxPublicKey: keyAndSignature.keys.offerPublicKey,
                                         requesterPublicKey: keyAndSignature.keys.senderPublicKey,
                                         signature: keyAndSignature.signature)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .sink { _ in
                print("FINISHED?!")
            }
            .store(in: cancelBag)
    }

    private func validateSignature(forOfferIndex index: Int) -> AnyPublisher<KeyAndSignature, Error> {
        let keys = offerAndSenderKeys[index]
        return chatService.requestChallenge(publicKey: keys.offerPublicKey)
            .flatMapLatest(with: self) { owner, challenge in
                owner.cryptoService.signECDSA(keys: ECCKeys(pubKey: keys.offerPublicKey, privKey: nil), message: challenge.challenge)
                    .map { KeyAndSignature(keys: keys, signature: $0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
