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
            .filter { $0 == .continueTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                owner.showRegisterPhoneContacts(router: owner.router)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        return finished
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension RegisterNameAvatarCoordinator {
    private func showRegisterPhoneContacts(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterPhoneContactsCoordinator(router: router, animated: true))
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
