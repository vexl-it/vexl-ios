//
//  HomeCoordinator.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 27.05.2022.
//

import Cleevio
import Foundation
import Combine

final class HomeCoordinator: BaseCoordinator<Void> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {
        let viewModel = HomeViewModel()
        let viewController = BaseViewController(rootView: HomeView(viewModel: viewModel))

        router.present(viewController, animated: true)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}
