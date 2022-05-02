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

    init(router: Router) {
        self.router = router
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = CreateOfferViewModel()
        let viewController = BaseViewController(rootView: CreateOfferView(viewModel: viewModel))

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        router.present(viewController, animated: true)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        let dismissByRouter = viewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return Publishers.Merge(dismiss, dismissByRouter)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
