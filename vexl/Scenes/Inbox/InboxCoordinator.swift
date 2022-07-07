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
            .compactMap { route -> (inboxKeys: ECCKeys, receiverKey: String, offerType: OfferType?)? in
                if case let .conversationTapped(inboxKeys, receiverKey, offerType) = route {
                    return (inboxKeys: inboxKeys, receiverKey: receiverKey, offerType: offerType)
                }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, keysAndOffer -> CoordinatingResult<RouterResult<Void>> in
                let modalRouter = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen)
                return owner.showChatMessage(router: modalRouter,
                                             inboxKeys: keysAndOffer.inboxKeys,
                                             receiverPublicKey: keysAndOffer.receiverKey,
                                             offerType: keysAndOffer.offerType)
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

    private func showChatMessage(router: Router,
                                 inboxKeys: ECCKeys,
                                 receiverPublicKey: String,
                                 offerType: OfferType?) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatCoordinator(inboxKeys: inboxKeys,
                                       receiverPublicKey: receiverPublicKey,
                                       offerType: offerType,
                                       router: router,
                                       animated: animated))
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
