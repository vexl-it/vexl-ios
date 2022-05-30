//
//  ChatMessageCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import Foundation
import Cleevio
import Combine

final class ChatMessageCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let id: String
    private let router: Router
    private let animated: Bool

    init(id: String, router: Router, animated: Bool) {
        self.id = id
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = ChatMessageViewModel()
        let viewController = BaseViewController(rootView: ChatMessageView(viewModel: viewModel))

        if let chatRouter = router as? CoinValueRouter {
            chatRouter.presentFullscreen(viewController, animated: true)
        } else {
            router.present(viewController, animated: true)
        }

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
