//
//  RequestOfferViewModel.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import Foundation
import Cleevio
import Combine

final class RequestOfferViewModel: ViewModelType, ObservableObject {

    @Inject var authenticationManager: AuthenticationManagerType
    @Inject var persistence: PersistenceStoreManagerType
    @Inject var chatManager: ChatManagerType

    @Fetched(fetchImmediately: false)
    var fetchedCommonFriends: [ManagedContact]

    enum State {
        case normal
        case requesting
    }

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case sendRequest
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var primaryActivity: Activity = .init()
    @Published var error: Error?
    @Published var state: State = .normal
    @Published var requestText: String = ""
    @Published var commonFriends: [ManagedContact] = []

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    var offerViewData: OfferDetailViewData {
        OfferDetailViewData(offer: offer)
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case requestSent
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var username: String

    private let offer: ManagedOffer
    private let cancelBag: CancelBag = .init()

    init(offer: ManagedOffer) {
        self.offer = offer
        self.username = self.offer.receiversPublicKey?.profile?.name ?? ""
        setupDataBindings()
        setupActivityBindings()
        setupActionBindings()
    }

    private func setupDataBindings() {
        if let commonFriends = offer.commonFriends, !commonFriends.isEmpty {
            let array = NSArray(array: offer.commonFriends ?? [])
            $fetchedCommonFriends
                .load(predicate: NSPredicate(format: "hmacHash IN %@", array))

            $fetchedCommonFriends.publisher
                .map(\.objects)
                .assign(to: &$commonFriends)
        }
    }

    private func setupActivityBindings() {
        errorIndicator
            .errors
            .asOptional()
            .handleEvents(receiveOutput: { [weak self] error in
                if error != nil {
                    self?.state = .normal
                }
            })
            .assign(to: &$error)
    }

    private func setupActionBindings() {
        let userAction = action
            .share()

        userAction
            .filter { $0 == .dismissTap }
            .map { _ in Route.dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        userAction
            .filter { $0 == .sendRequest }
            .withUnretained(self)
            .compactMap { owner, _ -> MessagePayload? in
                guard let publicKey = owner.offer.inbox?.keyPair?.publicKey else {
                    return nil
                }
                return MessagePayload
                    .communicationRequest(inboxPublicKey: publicKey,
                                          text: owner.requestText,
                                          contactInboxKey: owner.authenticationManager.userKeys.publicKey)
            }
            .flatMapLatest(with: self) { owner, payload -> AnyPublisher<Void, Never> in
                owner.state = .requesting
                guard let publicKey = owner.offer.receiversPublicKey?.publicKey else {
                    return Just(()).eraseToAnyPublisher()
                }
                return owner.chatManager
                    .requestCommunication(offer: owner.offer, receiverPublicKey: publicKey, messagePayload: payload)
                    .trackError(owner.primaryActivity.error)
            }
            .flatMap { [persistence, offer] _ in
                persistence.update(context: persistence.viewContext) { _ in
                    offer.isRequested = true
                }
                .justOnError()
            }
            .map { Route.requestSent }
            .subscribe(route)
            .store(in: cancelBag)
    }
}
