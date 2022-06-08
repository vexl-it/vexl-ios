//
//  ChatCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import Foundation
import Cleevio
import Combine

final class ChatCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let id: String
    private let router: Router
    private let animated: Bool

    init(id: String, router: Router, animated: Bool) {
        self.id = id
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = ChatViewModel()
        let viewController = BaseViewController(rootView: ChatView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
