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
        let viewController = RegisterNameAvatarViewController(rootView: RegisterNameAvatarView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        let next = viewModel.route
            .filter { $0 == .continueTapped }
            .map { _ -> RouterResult<Void> in .finished(()) }

        let dismissByRouter = viewController
            .dismissPublisher
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismissByRouter
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
