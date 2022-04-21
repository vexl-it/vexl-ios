//
//  OffersCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import Foundation
import Cleevio

class OffersCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = OffersViewModel()
        let viewController = BaseViewController(rootView: OffersView(viewModel: viewModel))

        if let marketplaceRouter = router as? MarketplaceRouter {
            marketplaceRouter.presentFullscreen(viewController, animated: true)
        } else {
            router.present(viewController, animated: true)
        }

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }
            .handleEvents(receiveOutput: { _ in
                print("should dismiss")
            })

        return dismiss
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
