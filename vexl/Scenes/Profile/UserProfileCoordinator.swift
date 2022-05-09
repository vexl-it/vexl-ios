//
//  UserProfileCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import Cleevio
import Combine

final class UserProfileCoordinator: BaseCoordinator<Void> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {
        let viewModel = UserProfileViewModel()
        let viewController = BaseViewController(rootView: UserProfileView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}
