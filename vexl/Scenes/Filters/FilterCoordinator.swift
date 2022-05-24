//
//  FilterCoordinator.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 23.05.2022.
//

import Foundation
import Cleevio
import Combine

final class FilterCoordinator: BaseCoordinator<RouterResult<OfferFilter>> {

    private let router: Router
    private let offerFilter: OfferFilter

    init(router: Router, offerFilter: OfferFilter) {
        self.router = router
        self.offerFilter = offerFilter
    }

    override func start() -> CoordinatingResult<RouterResult<OfferFilter>> {
        let viewModel = FilterViewModel(offerFilter: offerFilter)
        let viewController = BaseViewController(rootView: FilterView(viewModel: viewModel))

        router.present(viewController, animated: true)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<OfferFilter> in .dismiss }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: OfferFilter.self)

        let filterApplied = viewModel
            .route
            .compactMap { route in
                switch route {
                case .applyFilterTapped(let filter):
                    return filter
                default:
                    return nil
                }
            }
            .map { RouterResult<OfferFilter>.finished($0) }

        return Publishers.Merge3(dismiss, dismissByRouter, filterApplied)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
