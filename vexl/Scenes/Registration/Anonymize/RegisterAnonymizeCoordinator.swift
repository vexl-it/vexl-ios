//
//  RegisterAnonymizeCoordinator.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 07.08.2022.
//

import Foundation
import Combine
import Cleevio

class RegisterAnonymizeCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool
    private let input: AnonymizeInput

    init(router: Router, animated: Bool, input: AnonymizeInput) {
        self.router = router
        self.animated = animated
        self.input = input
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = RegisterAnonymizeViewModel(input: input)
        let viewController = RegisterViewController(currentPage: 1,
                                                    numberOfPages: 4,
                                                    rootView: RegisterAnonymizeView(viewModel: viewModel),
                                                    showBackButton: false)
        router.present(viewController, animated: animated)

        // MARK: - ViewModel Bindings

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
                owner.showRegisterPhoneContacts(router: owner.router)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        return finished
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension RegisterAnonymizeCoordinator {
    private func showRegisterPhoneContacts(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterPhoneContactsCoordinator(router: router, animated: true))
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
