//
//  BuySellCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 10/04/22.
//

import Cleevio
import Foundation
import Combine

final class MarketplaceCoordinator: BaseCoordinator<Void> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {
        let bitcoinViewModel = BitcoinViewModel()
        let viewModel = MarketplaceViewModel(bitcoinViewModel: bitcoinViewModel)
        let viewController = BaseViewController(
            rootView: BitcoinContainerView(
                hasBitcoinViewModel: viewModel,
                content: MarketplaceView(viewModel: viewModel)
            )
        )

        router.present(viewController, animated: true)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showSellOfferTapped }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showSellOffers(router: owner.router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showBuyOfferTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showBuyOffers(router: modalRouter)
            }
            .sink()
            .store(in: cancelBag)

        setupFilterBindings(viewModel: viewModel, viewController: viewController)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }

    private func setupFilterBindings(viewModel: MarketplaceViewModel, viewController: UIViewController) {
        viewModel
            .route
            .receive(on: RunLoop.main)
            .compactMap { route -> OfferFilter? in
                if case let .showFiltersTapped(offerFilter) = route { return offerFilter }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, filter -> CoordinatingResult<RouterResult<OfferFilter>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showFilters(router: modalRouter, filter: filter)
            }
            .sink(receiveValue: { result in
                if case .finished(let filter) = result {
                    viewModel.applyFilter(filter)
                }
            })
            .store(in: cancelBag)
    }
}

extension MarketplaceCoordinator {
    private func showSellOffers(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: UserOffersCoordinator(router: router, offerType: .sell))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func showBuyOffers(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: UserOffersCoordinator(router: router, offerType: .buy))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func showFilters(router: Router, filter: OfferFilter) -> CoordinatingResult<RouterResult<OfferFilter>> {
        coordinate(to: FilterCoordinator(router: router, offerFilter: filter))
        .flatMap { result -> CoordinatingResult<RouterResult<OfferFilter>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }
}
