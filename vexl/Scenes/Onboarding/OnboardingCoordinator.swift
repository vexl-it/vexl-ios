//
//  OnboardingCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import Combine
import SwiftUI
import Cleevio

final class OnboardingCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = OnboardingViewModel()
        let viewController = BaseViewController(rootView: OnboardingView(viewModel: viewModel))

        // MARK: Routers

        router.present(viewController, animated: animated)

        // MARK: Routing actions

        let finished = viewModel
            .route
            .filter { $0 == .tapped }
            .receive(on: RunLoop.main)
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                owner.showLoginFlow(router: owner.router)
            }

        // MARK: Dismiss

        let dismiss = viewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return Publishers.Merge(dismiss, finished)
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}

private extension OnboardingCoordinator {
    func showLoginFlow(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: WelcomeCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .eraseToAnyPublisher()
    }
}
