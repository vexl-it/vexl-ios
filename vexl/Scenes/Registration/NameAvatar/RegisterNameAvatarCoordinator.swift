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
        let viewController = RegisterViewController(currentPage: 1,
                                                    numberOfPages: 4,
                                                    rootView: RegisterNameAvatarView(viewModel: viewModel),
                                                    showBackButton: false)
        router.present(viewController, animated: animated)

        viewController
            .onBack
            .sink { _ in
                viewModel.updateToPreviousState()
            }
            .store(in: cancelBag)

        // MARK: - ViewModel Bindings

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$loading
            .assign(to: &viewController.$isLoading)

        viewModel
            .$currentState
            .map { $0 == .avatarInput }
            .assign(to: &viewController.$showBackButton)

        let finished = viewModel
            .route
            .receive(on: RunLoop.main)
            .map { route -> AnonymizeInput in
                switch route {
                case .continueTapped(let input):
                    return input
                }
            }
            .withUnretained(self)
            .flatMap { owner, input -> CoordinatingResult<RouterResult<Void>> in
                owner.showAnonymizeUser(router: owner.router, input: input)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        return finished
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension RegisterNameAvatarCoordinator {
    private func showAnonymizeUser(router: Router, input: AnonymizeInput) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(
            to: RegisterAnonymizeCoordinator(
                router: router,
                animated: true,
                input: input
            )
        )
        .prefix(1)
        .eraseToAnyPublisher()
    }
}
