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
        print("LOGIN COORDINATOR DEINIT")
    }

    lazy var registrationCoordinator = RegistrationCoordinator(router: router, animated: true)

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = LoginViewModel()
        let viewController = BaseViewController(rootView: LoginView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        // Routing actions

        // Result

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showRegistration }
            .flatMap { [weak self] route -> CoordinatingResult<RouterResult<Void>> in
                guard let owner = self else {
                    return Empty<CoordinationResult, Never>(completeImmediately: true).eraseToAnyPublisher()
                }
                return owner.showRegistration()
            }
            .receive(on: RunLoop.main)
            .flatMap { [weak self] result -> CoordinatingResult<RouterResult<Void>> in
                guard let owner = self, result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return owner.router.dismiss(animated: true, returning: result)
            }
            .sink(receiveValue: { result in
                print(result)
            })
            .store(in: cancelBag)

        let dismissByRouter = viewController.dismissPublisher
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<Void>.dismissedByRouter }

        let dismiss = viewModel.route
            .receive(on: RunLoop.main)
            .filter { $0 == .dismissTapped }
            .flatMap { route -> CoordinatingResult<RouterResult<Void>> in
                return Just(.dismiss).eraseToAnyPublisher()
            }

        return Publishers.Merge(dismiss, dismissByRouter)
            .eraseToAnyPublisher()
    }
}

private extension LoginCoordinator {
    func showRegistration() -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: registrationCoordinator)
    }
}
