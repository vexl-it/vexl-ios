//
//  RegisterPhoneContactsCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import Foundation
import Combine
import Cleevio

final class RegisterPhoneContactsCoordinator: BaseCoordinator<RouterResult<Void>> {

    @Inject var userRepository: UserRepositoryType

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = RegisterPhoneContactsViewModel()
        let viewController = RegisterViewController(currentPage: 2,
                                                    numberOfPages: Constants.registrationSteps,
                                                    rootView: RegisterPhoneContactsView(viewModel: viewModel),
                                                    showBackButton: false)

        router.present(viewController, animated: animated)

        // MARK: - ViewModel Bindings

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$loading
            .assign(to: &viewController.$isLoading)

        let skipTap = viewModel
            .route
            .filter { $0 == .skipTapped }
            .map { _ in RouterResult<Void>.finished(()) }

        let continueTap = viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .continueTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                owner.showFacebooKContacts(router: owner.router)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        return Publishers.Merge(skipTap, continueTap)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension RegisterPhoneContactsCoordinator {
    private func showFacebooKContacts(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterFacebookContactsCoordinator(router: router, animated: true))
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
