//
//  ChatRequestViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 26/05/22.
//

import Foundation
import Cleevio
import Combine

private typealias OfferKeyAndMessage = (offer: Offer, key: UserOfferKeys.OfferKey, message: ParsedChatMessage)
private typealias OfferKeysAndMessages = (keys: [UserOfferKeys.OfferKey], messages: [ParsedChatMessage])
private typealias OfferKeyAndSenderKey = (offerKey: UserOfferKeys.OfferKey, senderPublicKey: String)
private typealias OfferSenderAndViewData = (keys: OfferKeyAndSenderKey, viewData: ChatRequestOfferViewData)
private typealias KeyAndSignature = (keys: OfferKeyAndSenderKey, signature: String)
private typealias IndexAndConfirmation = (index: Int, confirmation: Bool)
private typealias KeySignatureAndConfirmation = (keys: OfferKeyAndSenderKey, signature: String, confirmation: Bool)

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

    private var offerAndSenderKeys: [OfferKeyAndSenderKey] = []
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
        let offerKeys = offerService
            .getOfferKeys()
            .withUnretained(self)
            .flatMap { owner, keys -> AnyPublisher<OfferKeysAndMessages, Error> in
                owner.chatService
                    .getRequestMessages()
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { OfferKeysAndMessages(keys: keys, messages: $0) }
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

        let getOffers = offerKeys
            .withUnretained(self)
            .flatMap { owner, offerKeysAndMessages -> AnyPublisher<[OfferKeyAndMessage], Error> in
                owner.offerService
                    .getUserOffers(offerIds: offerKeysAndMessages.keys.map { $0.id })
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .map { encryptedOffers -> [OfferKeyAndMessage] in
                        var offerKeyAndMessages: [OfferKeyAndMessage] = []
                        let decryptedOffers = Offer.createOffers(from: encryptedOffers, withKey: owner.userSecurity.userKeys)
                        for message in offerKeysAndMessages.messages {
                            if let decryptedOffer = decryptedOffers.first(where: { $0.offerPublicKey == message.from }),
                               let key = offerKeysAndMessages.keys.first(where: { $0.id == decryptedOffer.offerId }) {
                                offerKeyAndMessages.append(OfferKeyAndMessage(offer: decryptedOffer, key: key, message: message))
                            }
                        }
                        return offerKeyAndMessages
                    }
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

        getOffers
            .withUnretained(self)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { owner, offerKeyAndMessages in
                let offerRequests = offerKeyAndMessages.map { offer, key, message -> OfferSenderAndViewData in
                    let offerDetailViewData = OfferDetailViewData(offer: offer, isRequested: false)
                    let keys = OfferKeyAndSenderKey(offerKey: key, senderPublicKey: message.key)
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
                    if let index = owner.offerRequests.firstIndex(where: { $0.id == id }) {
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
            .flatMapLatest(with: self) { owner, keySignatureAndConfirmation -> AnyPublisher<Void, Never> in

                let message = ParsedChatMessage.createRequestConfirmation(isConfirmed: keySignatureAndConfirmation.confirmation,
                                                                          inboxPublicKey: keySignatureAndConfirmation.keys.offerKey.publicKey,
                                                                          senderKey: keySignatureAndConfirmation.keys.senderPublicKey)

                return owner.chatService
                    .requestConfirmation(confirmation: keySignatureAndConfirmation.confirmation,
                                         message: message?.asString(withKey: keySignatureAndConfirmation.keys.offerKey.key) ?? "",
                                         inboxPublicKey: keySignatureAndConfirmation.keys.offerKey.publicKey,
                                         requesterPublicKey: keySignatureAndConfirmation.keys.senderPublicKey,
                                         signature: keySignatureAndConfirmation.signature)
                    .track(activity: owner.primaryActivity)
                    .materialize()
                    .compactMap(\.value)
                    .eraseToAnyPublisher()
            }
            .sink { _ in
                print("FINISHED?!")
            }
            .store(in: cancelBag)
    }

    private func validateSignature(forOfferIndex index: Int, confirmation: Bool) -> AnyPublisher<KeySignatureAndConfirmation, Error> {
        let keys = offerAndSenderKeys[index]
        return chatService.requestChallenge(publicKey: keys.offerKey.publicKey)
            .flatMapLatest(with: self) { owner, challenge in
                owner.cryptoService.signECDSA(keys: keys.offerKey.key,
                                              message: challenge.challenge)
                    .map { KeyAndSignature(keys: keys, signature: $0) }
                    .eraseToAnyPublisher()
            }
            .map { KeySignatureAndConfirmation(keys: $0.keys, signature: $0.signature, confirmation: confirmation) }
            .eraseToAnyPublisher()
    }
}
