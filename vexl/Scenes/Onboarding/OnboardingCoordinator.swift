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

        router.present(viewController, animated: animated)

        // MARK: Routers

        // MARK: Routing actions

        viewModel
            .route
            .receive(on: RunLoop.main)
            .flatMap { [weak self] route -> CoordinatingResult<RouterResult<Void>> in
                guard let owner = self else {
                    return Just(.dismiss).eraseToAnyPublisher()
                }
                switch route {
                case .tapped:
                    return owner.showLoginFlow(router: owner.router)
                }
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        // MARK: Dismiss

        let dismiss = viewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismiss
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}

private extension OnboardingCoordinator {
    func showLoginFlow(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: LoginCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .eraseToAnyPublisher()
    }
}
