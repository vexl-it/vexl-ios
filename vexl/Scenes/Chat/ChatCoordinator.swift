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

    private let router: CoinValueRouter
    private let animated: Bool

    init(router: CoinValueRouter, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {

        let viewModel = ChatViewModel()
        let viewController = BaseViewController(rootView: ChatView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        viewModel
            .route
            .filter { $0 == .requestTapped }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showChatRequests(router: owner.router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .compactMap { route -> String? in
                if case let .messageTapped(id) = route { return id }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, id in
                owner.showChatMessage(router: owner.router, id: id)
            }
            .sink()
            .store(in: cancelBag)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}

extension ChatCoordinator {
    private func showChatRequests(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatRequestCoordinator(router: router, animated: animated))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func showChatMessage(router: Router, id: String) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatMessageCoordinator(id: id, router: router, animated: animated))
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
