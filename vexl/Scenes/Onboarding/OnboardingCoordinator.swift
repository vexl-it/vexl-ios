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
            .filter { $0 == .skipTapped }
            .receive(on: RunLoop.main)
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                owner.showWelcome(router: owner.router)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        // MARK: Dismiss

        let dismiss = viewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return finished//Publishers.Merge(dismiss, finished)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

private extension OnboardingCoordinator {
    func showWelcome(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: WelcomeCoordinator(router: router, animated: true))
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
