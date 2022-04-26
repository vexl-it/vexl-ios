//
//  RegisterPhoneContactsCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import Combine
import Cleevio

final class RegisterContactsCoordinator: BaseCoordinator<RouterResult<Void>> {

    @Inject var authenticationManager: AuthenticationManagerType

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = RegisterContactsViewModel(username: authenticationManager.currentUser?.username ?? "",
                                                  avatar: authenticationManager.currentUser?.avatarImage)
        let viewController = RegisterViewController(currentPage: 2, numberOfPages: 3, rootView: RegisterContactsView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$loading
            .assign(to: &viewController.$isLoading)

        let dismissByRouter = viewController
            .dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        let skipTap = viewModel
            .route
            .filter { $0 == .skipTapped }
            .map { _ in RouterResult<Void>.dismissedByRouter }

        let continueTap = viewModel
            .route
            .filter { $0 == .continueTapped }
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return Publishers.Merge3(skipTap, continueTap, dismissByRouter)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
