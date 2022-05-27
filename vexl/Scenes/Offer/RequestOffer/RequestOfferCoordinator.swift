//
//  RequestOfferCoordinator.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import Foundation
import Cleevio
import Combine

final class RequestOfferCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let offer: Offer

    init(router: Router, offer: Offer) {
        self.router = router
        self.offer = offer
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = RequestOfferViewModel(offer: offer)
        let viewController = ToggleKeyboardBaseViewController(rootView: RequestOfferView(viewModel: viewModel))

        router.present(viewController, animated: true)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        let requestSent = viewModel
            .route
            .filter { $0 == .requestSent }
            .map { _ -> RouterResult<Void> in .finished(()) }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: Void.self)

        return Publishers.Merge3(requestSent, dismiss, dismissByRouter)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
