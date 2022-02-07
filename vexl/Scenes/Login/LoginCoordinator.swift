//
//  LoginCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import Combine
import SwiftUI
import Cleevio

final class LoginCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = LoginViewModel()
        let viewController = BaseViewController(rootView: LoginView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        // Routing actions

        // Result

        let dismissByRouter = viewController.dismissPublisher
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<Void>.dismissedByRouter }

        let dismiss = viewModel.route
            .receive(on: RunLoop.main)
            .flatMap { route -> CoordinatingResult<RouterResult<Void>> in
                switch route {
                case .dismissTapped:
                    return Just(.dismiss).eraseToAnyPublisher()
                }
            }

        return Publishers.Merge(dismiss, dismissByRouter)
            .eraseToAnyPublisher()
    }
}

private extension OnboardingCoordinator {
}
