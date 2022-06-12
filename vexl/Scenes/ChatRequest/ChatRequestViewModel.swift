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
private typealias IndexAndConfirmation = (index: Int, confirmation: Bool)
private typealias KeySignatureAndConfirmation = (keys: OfferAndSenderKey, signature: String, confirmation: Bool)

final class ChatRequestViewModel: ViewModelType, ObservableObject {

    @Inject var userSecurity: UserSecurityType
    @Inject var chatService: ChatServiceType
    @Inject var offerService: OfferServiceType
    @Inject var cryptoService: CryptoServiceType

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
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
            .withUnretained(self)
            .flatMap { owner, ids -> AnyPublisher<OfferIdsAndMessages, Error> in
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
            .withUnretained(self)
            .flatMap { owner, offerIdsAndMessages -> AnyPublisher<[OfferAndMessage], Error> in
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
            .compactMap { owner, action -> IndexAndConfirmation? in
                switch action {
                case let .confirmationTap(id, confirmation):
                    if let index = owner.offerRequests.firstIndex(where: { $0.offer.id == id }) {
                        return IndexAndConfirmation(index: index, confirmation: confirmation)
                    }
                    return nil
                default:
                    return nil
                }
            }
            .flatMapLatest(with: self) { owner, indexAndConfirmation in
                owner.validateSignature(forOfferIndex: indexAndConfirmation.index, confirmation: indexAndConfirmation.confirmation)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .flatMapLatest(with: self) { owner, keySignatureAndConfirmation in
                owner.chatService
                    .requestConfirmation(confirmation: keySignatureAndConfirmation.confirmation,
                                         message: "",
                                         inboxPublicKey: keySignatureAndConfirmation.keys.offerPublicKey,
                                         requesterPublicKey: keySignatureAndConfirmation.keys.senderPublicKey,
                                         signature: keySignatureAndConfirmation.signature)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
            }
            .sink { _ in
                print("FINISHED?!")
            }
            .store(in: cancelBag)
    }

    private func validateSignature(forOfferIndex index: Int, confirmation: Bool) -> AnyPublisher<KeySignatureAndConfirmation, Error> {
        let keys = offerAndSenderKeys[index]
        return chatService.requestChallenge(publicKey: keys.offerPublicKey)
            .flatMapLatest(with: self) { owner, challenge in
                owner.cryptoService.signECDSA(keys: ECCKeys(pubKey: keys.offerPublicKey, privKey: nil), message: challenge.challenge)
                    .map { KeyAndSignature(keys: keys, signature: $0) }
                    .eraseToAnyPublisher()
            }
            .map { KeySignatureAndConfirmation(keys: $0.keys, signature: $0.signature, confirmation: confirmation) }
            .eraseToAnyPublisher()
    }
}
