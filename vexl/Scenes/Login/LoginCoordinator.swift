//
//  LoginCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import Combine
import SwiftUI
import Cleevio

enum LoginResult {
    case streamingValues
    case finished
}

final class LoginCoordinator: BaseCoordinator<RouterResult<Void>> {

    let publisher = PassthroughSubject<String, Never>()
    private let router: Router
    private let animated: Bool

    deinit {
        print("LOGIN COORDINATOR DEINIT")
    }

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = LoginViewModel()

        // TODO: discuss with team
        // We need to set the presentation controller delegate ONLY when showing the modal. So we can use the router to know if it's modal or not
        let viewController = BaseViewController(rootView: LoginView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 != .dismissTapped }
            .flatMap { route -> CoordinatingResult<RouterResult<Void>> in
                switch route {
                case .dismissTapped:
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        let dismissByRouter = dismissObservable(from: viewController, router: router)
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<Void>.dismissedByRouter }

        let dismiss = viewModel.route
            .receive(on: RunLoop.main)
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return Publishers.Merge(dismiss, dismissByRouter)
            .eraseToAnyPublisher()
    }
}

private extension LoginCoordinator { }
