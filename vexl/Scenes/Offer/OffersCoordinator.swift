//
//  OffersCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import Foundation
import Cleevio
import Combine

class OffersCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = OffersViewModel()
        let viewController = BaseViewController(rootView: OffersView(viewModel: viewModel))

        if let homeRouter = router as? HomeRouter {
            homeRouter.presentFullscreen(viewController, animated: true)
        } else {
            router.present(viewController, animated: true)
        }

        viewModel
            .route
            .filter { $0 == .createOfferTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showCreateOffer(router: modalRouter)
            }
            .sink { _ in }
            .store(in: cancelBag)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension OffersCoordinator {
    private func showCreateOffer(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: CreateOfferCoordinator(router: router))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
