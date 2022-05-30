//
//  ChatCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio
import Combine

final class ChatCoordinator: BaseCoordinator<Void> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {
        let viewModel = ChatViewModel()
        let viewController = BaseViewController(rootView: ChatView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}
