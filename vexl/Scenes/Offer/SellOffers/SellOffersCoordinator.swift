//
//  OffersCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import Foundation
import Cleevio
import Combine

final class SellOffersCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = SellOffersViewModel()
        let viewController = BaseViewController(rootView: SellOffersView(viewModel: viewModel))

        if let homeRouter = router as? HomeRouter {
            homeRouter.presentFullscreen(viewController, animated: true)
        } else {
            router.present(viewController, animated: true)
        }

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        viewModel
            .route
            .filter { $0 == .createOfferTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showCreateOffer(router: modalRouter)
            }
            .sink { result in
                switch result {
                case .finished:
                    viewModel.refreshOffers()
                default:
                    break
                }
            }
            .store(in: cancelBag)

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

extension SellOffersCoordinator {
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
