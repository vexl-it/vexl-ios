//
//  GroupsCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 01.08.2022.
//

import Foundation
import Cleevio
import Combine

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

        viewModel
            .route
            .filter { $0 == .joinGroupTapped }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.presentGroupScanQR(router: owner.router)
            }
            .sink()
            .store(in: cancelBag)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}

extension GroupsCoordinator {
    private func presentGroupScanQR(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: GroupsScanQRCoordinator(router: router, animated: true))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }
}
