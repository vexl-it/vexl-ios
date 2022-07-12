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

        let finished = viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .continueTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                owner.showRegisterPhone(router: owner.router)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        // MARK: Dismiss

        return finished
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

private extension WelcomeCoordinator {
    func showRegisterPhone(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterPhoneCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                switch result {
                case .dismiss:
                    return router.dismiss(animated: true, returning: result)
                case .finished, .dismissedByRouter:
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
