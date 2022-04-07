//
//  RegisterNameAvatarCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import Foundation
import Combine
import Cleevio

class RegisterNameAvatarCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = RegisterNameAvatarViewModel()
        let viewController = RegisterViewController(currentPage: 1, numberOfPages: 3, rootView: RegisterNameAvatarView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$loading
            .assign(to: &viewController.$loading)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .continueTapped }
            .withUnretained(self)
            .flatMap { owner, route -> CoordinatingResult<RouterResult<Void>> in
                switch route {
                case .continueTapped:
                    return owner.showRegisterPhoneContacts(router: owner.router)
                }
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        let dismissByRouter = viewController
            .dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissByRouter
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}

extension RegisterNameAvatarCoordinator {
    private func showRegisterPhoneContacts(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterContactsCoordinator(router: router, animated: true))
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
