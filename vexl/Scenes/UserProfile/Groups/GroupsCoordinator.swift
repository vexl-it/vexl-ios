//
//  GroupsCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 01.08.2022.
//

import Foundation
import Cleevio

final class GroupsCoordinator: BaseCoordinator<RouterResult<Void>> {

    let animated: Bool
    let router: Router

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {

        let viewModel = GroupsViewModel()
        let viewController = BaseViewController(rootView: GroupsView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
