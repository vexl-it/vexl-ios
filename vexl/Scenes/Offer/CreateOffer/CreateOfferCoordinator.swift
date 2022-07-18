//
//  CreateOfferCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 21/04/22.
//

import Foundation
import Cleevio
import Combine

final class CreateOfferCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let offerType: OfferType

    init(router: Router, offerType: OfferType) {
        self.router = router
        self.offerType = offerType
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = CreateOfferViewModel(offerType: offerType)
        let viewController = BaseViewController(rootView: CreateOfferView(viewModel: viewModel))

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
            .filter {
                $0 == .offerCreated
            }
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
