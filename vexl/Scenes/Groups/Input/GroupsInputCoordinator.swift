//
//  GroupsManualInputCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import Foundation
import Cleevio
import Combine

final class GroupsInputCoordinator: BaseCoordinator<RouterResult<Void>> {

    let animated: Bool
    let router: Router
    let fromDeeplink: Bool
    let code: String?

    init(router: Router, animated: Bool, code: String? = nil, fromDeeplink: Bool = false) {
        self.router = router
        self.animated = animated
        self.code = code
        self.fromDeeplink = fromDeeplink
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {

        let viewModel = GroupsInputViewModel(code: self.code, fromDeeplink: fromDeeplink)
        let viewController = GroupViewController(rootView: GroupsInputView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        let continueTap = viewModel
            .route
            .map { _ -> RouterResult<Void> in .finished(()) }

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: Void.self)

        return Publishers.Merge3(dismiss, continueTap, dismissByRouter)
            .eraseToAnyPublisher()
    }
}
