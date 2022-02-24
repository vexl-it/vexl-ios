//
//  LoginCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import Combine
import SwiftUI
import Cleevio

enum WelcomeResult {
    case streamingValues
    case finished
}

final class WelcomeCoordinator: BaseCoordinator<RouterResult<Void>> {

    let publisher = PassthroughSubject<String, Never>()
    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = WelcomeViewModel()
        let viewController = WelcomeViewController(rootView: WelcomeView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        // MARK: Routers

        // MARK: Routing actions

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 != .dismissTapped }
            .withUnretained(self)
            .flatMap { owner, route -> CoordinatingResult<RouterResult<Void>> in
                switch route {
                case .dismissTapped:
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                case .continueTapped:
                    return owner.showRegisterPhone(router: owner.router)
                }
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        // MARK: Dismiss

        let dismissByRouter = viewController.dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        let dismiss = viewModel.route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return Publishers.Merge(dismiss, dismissByRouter)
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}

private extension WelcomeCoordinator {
    func showRegisterPhone(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterPhoneCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .eraseToAnyPublisher()
    }
}
