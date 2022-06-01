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

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    var offerFeed: OfferDetailViewData {
        OfferFeed.mapToOfferFeed(usingOffer: offer).viewData
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
        case requestSent
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    @Inject private var offerService: OfferServiceType
    private let offer: Offer
    private let cancelBag: CancelBag = .init()

    init(offer: Offer) {
        self.offer = offer
        setupActivityBindings()
        setupActionBindings()
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
            .flatMapLatest(with: self) { owner, _ -> AnyPublisher<Void, Never> in
                owner.state = .requesting
                return owner.offerService.requestOffer(offerId: owner.offer.offerId, string: owner.requestText)
                    .trackError(owner.primaryActivity.error)
            }
            .map { _ in Route.requestSent }
            .subscribe(route)
            .store(in: cancelBag)
    }
}