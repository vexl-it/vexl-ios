//
//  ChatCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 9/05/22.
//

import Foundation
import Cleevio
import Combine

final class InboxCoordinator: BaseCoordinator<Void> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {
        let viewModel = InboxViewModel(bitcoinViewModel: .init())
        let viewController = BaseViewController(rootView: InboxView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        viewModel
            .route
            .filter { $0 == .requestTapped }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showChatRequests(router: modalRouter)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .compactMap { route -> (inboxKeys: ECCKeys, recieverKey: String)? in
                if case let .messageTapped(inboxKeys, receiverKey) = route { return (inboxKeys: inboxKeys, recieverKey: receiverKey) }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, keys -> CoordinatingResult<RouterResult<Void>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showChatMessage(router: modalRouter, inboxKeys: keys.inboxKeys, receiverPublicKey: keys.recieverKey)
            }
            .sink()
            .store(in: cancelBag)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}

extension InboxCoordinator {
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

    private func showChatMessage(router: Router, inboxKeys: ECCKeys, receiverPublicKey: String) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatCoordinator(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey, router: router, animated: animated))
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
