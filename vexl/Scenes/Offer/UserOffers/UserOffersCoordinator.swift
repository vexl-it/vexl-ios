//
//  OffersCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 20/04/22.
//

import Foundation
import Cleevio
import Combine

final class UserOffersCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let offerType: OfferType

    init(router: Router, offerType: OfferType) {
        self.router = router
        self.offerType = offerType
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = UserOffersViewModel(offerType: offerType)
        let viewController = BaseViewController(rootView: UserOffersView(viewModel: viewModel))

        router.present(viewController, animated: true)

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
                return owner.showCreateOffer(router: modalRouter, offerType: owner.offerType)
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

extension UserOffersCoordinator {
    private func showCreateOffer(router: Router, offerType: OfferType) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: CreateOfferCoordinator(router: router, offerType: offerType))
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
