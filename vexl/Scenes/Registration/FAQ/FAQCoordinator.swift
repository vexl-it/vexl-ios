//
//  FAQCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 4/08/22.
//

import Foundation
import Combine
import Cleevio

final class FAQCoordinator: BaseCoordinator<RouterResult<Void>> {

    let router: Router
    let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = FAQViewModel()
        let viewController = BaseViewController(rootView: FAQView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        let dismiss = viewModel
            .route
            .filter { $0 == .continueTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
