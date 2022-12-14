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

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        let manualInput = viewModel
            .route
            .filter { $0 == .manualInputTapped }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.presentGroupInput(router: owner.router)
            }
            .filter { result in
                if case .finished = result { return true }
                return false
            }

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped || $0 == .codeScanned }
            .map { _ -> RouterResult<Void> in .dismiss }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: Void.self)

        return Publishers.Merge3(dismiss, manualInput, dismissByRouter)
            .eraseToAnyPublisher()
    }
}

extension GroupsScanQRCoordinator {
    private func presentGroupInput(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: GroupsInputCoordinator(router: router, animated: true))
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
