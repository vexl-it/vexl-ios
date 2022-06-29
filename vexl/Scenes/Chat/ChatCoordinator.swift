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

    private let inboxKeys: ECCKeys
    private let receiverPublicKey: String
    private let offerType: OfferType?
    private let router: Router
    private let animated: Bool

    init(inboxKeys: ECCKeys, receiverPublicKey: String, offerType: OfferType?, router: Router, animated: Bool) {
        self.inboxKeys = inboxKeys
        self.receiverPublicKey = receiverPublicKey
        self.offerType = offerType
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = ChatViewModel(inboxKeys: inboxKeys, receiverPublicKey: receiverPublicKey, offerType: offerType)
        let viewController = BaseViewController(rootView: ChatView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        viewModel
            .route
            .compactMap { action -> Data? in
                if case let .expandImageTapped(image) = action { return image }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, image -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen, transitionStyle: .coverVertical)
                return owner.showChatExpandedImage(router: router, image: image)
            }
            .sink()
            .store(in: cancelBag)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}

extension ChatCoordinator {
    private func showChatExpandedImage(router: Router, image: Data) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatExpandedImageCoordinator(image: image, router: router, animated: animated))
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
