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

    deinit {
        print("ONBOARDING COORDINATOR DEINIT")
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = OnboardingViewModel()
        let viewController = BaseViewController(rootView: OnboardingView(viewModel: viewModel))

        // MARK: Routers

        let modalRouter = ModalRouter(parentViewController: viewController)

        // MARK: Child coordinators

        router.present(viewController, animated: animated)

        // Routing actions

        viewModel
            .route
            .receive(on: RunLoop.main)
            .flatMap { [weak self] route -> CoordinatingResult<RouterResult<Void>> in
                guard let owner = self else {
                    return Just(.dismiss).eraseToAnyPublisher()
                }
                switch route {
                case .tapped:
                    return owner.showLogin(router: owner.router)
                }
            }
            .receive(on: RunLoop.main)
            .flatMap { [weak self] result -> CoordinatingResult<RouterResult<Void>> in
                guard let owner = self, result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return owner.router.dismiss(animated: true, returning: result)
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        // Result

        let dismiss = viewController.dismissPublisher
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismiss
            .eraseToAnyPublisher()
    }
}

private extension OnboardingCoordinator {
    func showLogin(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: LoginCoordinator(router: router, animated: true))
    }
}
