//
//  TermsAndConditionsCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import Foundation
import Combine
import Cleevio

final class TermsAndConditionsCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = TermsAndConditionsViewModel()
        let viewController = BaseViewController(rootView: TermsAndConditionsView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
