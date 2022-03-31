//
//  RegisterPhoneContactsCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import Combine
import Cleevio

class RegisterContactsCoordinator: BaseCoordinator<RouterResult<Void>> {

    @Inject var authenticationManager: AuthenticationManager

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = RegisterContactsViewModel(username: authenticationManager.currentUser?.username ?? "")
        let viewController = RegisterViewController(currentPage: 2, numberOfPages: 3, rootView: RegisterContactsView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        let dismissByRouter = viewController
            .dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissByRouter
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
