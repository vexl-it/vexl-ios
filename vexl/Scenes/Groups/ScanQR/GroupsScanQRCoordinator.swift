//
//  GroupScanQRCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import Cleevio
import Combine

final class GroupsScanQRCoordinator: BaseCoordinator<RouterResult<Void>> {

    let animated: Bool
    let router: Router

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {

        let viewModel = GroupsScanQRViewModel()
        let viewController = GroupViewController(rootView: GroupsScanQRView(viewModel: viewModel))
        viewController.title = L.groupsScanCode()
        router.present(viewController, animated: animated)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
