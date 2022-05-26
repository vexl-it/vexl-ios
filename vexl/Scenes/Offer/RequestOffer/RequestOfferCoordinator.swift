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

    init(router: Router) {
        self.router = router
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = RequestOfferViewModel()
        let viewController = BaseViewController(rootView: RequestOfferView(viewModel: viewModel))

        router.present(viewController, animated: true)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: Void.self)

        return Publishers.Merge(dismiss, dismissByRouter)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
