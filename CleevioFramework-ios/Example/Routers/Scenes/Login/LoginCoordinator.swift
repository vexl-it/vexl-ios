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
    
    deinit {
        print("\(self) DEINIT")
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = LoginViewModel()
        let viewController = BaseViewController(rootView: LoginView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 != .dismissTapped }
            .flatMap { [weak self] route -> CoordinatingResult<RouterResult<Void>> in
                guard let owner = self else {
                    return Just(.dismiss).eraseToAnyPublisher()
                }
                switch route {
                case .showRegistration:
                    return owner.showRegistrationFlow(router: owner.router)
                case .dismissTapped:
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        let dismiss = viewModel.route
            .receive(on: RunLoop.main)
            .filter { $0 == .dismissTapped }
            .flatMap { _ -> CoordinatingResult<RouterResult<Void>> in
                Just(.dismiss).eraseToAnyPublisher()
            }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: Void.self)

        return Publishers.Merge(dismiss, dismissByRouter)
            .eraseToAnyPublisher()
    }
}

private extension LoginCoordinator {
    func showRegistrationFlow(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegistrationCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
