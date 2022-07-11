//
//  CreateOfferCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import Foundation
import Cleevio
import Combine

final class OfferCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let offer: Offer?
    private let offerType: OfferType

    init(router: Router, offerType: OfferType, offer: Offer?) {
        self.router = router
        self.offer = offer
        self.offerType = offerType
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel: OfferActionViewModel

        if let offer = offer {
            viewModel = OfferEditViewModel(offerType: offerType, offer: offer)
        } else {
            viewModel = OfferCreateViewModel(offerType: offerType)
        }

        let viewController = BaseViewController(rootView: OfferView(viewModel: viewModel))

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$state
            .sink { state in
                viewController.isLoading = state != .loaded
            }
            .store(in: cancelBag)

        let finished = viewModel
            .route
            .filter { $0 == .offerCreated }
            .map { _ -> RouterResult<Void> in .finished(()) }

        router.present(viewController, animated: true)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: Void.self)

        return Publishers.Merge3(dismiss, dismissByRouter, finished)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
