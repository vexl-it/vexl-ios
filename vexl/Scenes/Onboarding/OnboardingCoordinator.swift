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

        router.present(viewController, animated: true)

        // Routing actions

        viewModel
            .route
            .withUnretained(self)
            .flatMap { owner, route -> CoordinatingResult<RouterResult<Void>> in
                switch route {
                case .tapped:
                    return owner.showOnboarding(router: owner.router)
                }
            }
            .withUnretained(self)
            .flatMap { owner, result in
                owner.router.dismiss(animated: true, returning: result)
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        // Result

        let dismiss = viewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismiss
            .eraseToAnyPublisher()
    }
}

private extension OnboardingCoordinator {
    func showOnboarding(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: OnboardingCoordinator(router: router, animated: true))
    }
}
