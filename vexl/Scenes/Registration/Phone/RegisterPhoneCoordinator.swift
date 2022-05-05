//
//  RegisterPhoneCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import Foundation
import Combine
import Cleevio

class RegisterPhoneCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = RegisterPhoneViewModel()
        let viewController = RegisterViewController(currentPage: 0, numberOfPages: 3, rootView: RegisterPhoneView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewController
            .onBack
            .sink { _ in
                viewModel.updateToPreviousState()
            }
            .store(in: cancelBag)

        // MARK: - ViewModel bindings

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$loading
            .assign(to: &viewController.$isLoading)

        let finished = viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .continueTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                owner.showRegisterNameAvatar(router: owner.router)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        let back = viewModel
            .route
            .filter { $0 == .backTapped }
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<Void>.dismiss }

        return Publishers.Merge(finished, back)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension RegisterPhoneCoordinator {

    private func showRegisterNameAvatar(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterNameAvatarCoordinator(router: router, animated: true))
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
