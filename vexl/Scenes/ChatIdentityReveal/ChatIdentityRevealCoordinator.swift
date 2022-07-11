//
//  ChatIdentityRevealCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 7/07/22.
//

import Foundation
import Cleevio

final class ChatIdentityRevealCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool
    private let isUserResponse: Bool

    init(isUserResponse: Bool, router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
        self.isUserResponse = isUserResponse
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = ChatIdentityRevealViewModel(isUserResponse: isUserResponse)
        let viewController = BaseViewController(rootView: ChatIdentityRevealView(viewModel: viewModel))

        router.present(viewController, animated: true)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
