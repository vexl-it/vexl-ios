//
//  ChatCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import Foundation
import Cleevio
import Combine

private typealias ActionSheetResult = CoordinatingResult<RouterResult<BottomActionSheetActionType>>

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

        bindDeleteRoute(viewModel: viewModel, viewController: viewController)

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

        viewModel
            .route
            .compactMap { action -> Offer? in
                if case let .showOfferTapped(offer) = action { return offer }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, offer -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatOfferActionSheetViewModel(offer: offer))
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .filter { $0 == .showRevealIdentityTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatIdentityRequestViewModel())
            }
            .filter(Self.filterPrimaryAction)
            .sink { _ in
                viewModel.requestIdentityReveal()
            }
            .store(in: cancelBag)

        viewModel
            .route
            .filter { $0 == .showRevealIdentityResponseTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatIdentityResponseViewModel())
            }
            .compactMap { result -> BottomActionSheetActionType? in
                if case let .finished(actionType) = result { return actionType }
                return nil
            }
            .sink { action in
                viewModel.identityRevealResponse(isAccepted: action == .primary)
            }
            .store(in: cancelBag)

        // swiftlint: disable discouraged_optional_boolean
        viewModel
            .route
            .compactMap { action -> Bool? in
                if case let .showRevealIdentityModal(isUserResponse) = action { return isUserResponse }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, isUserResponse -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .coverVertical)
                return owner.showRevealIdentity(router: router, isUserResponse: isUserResponse)
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

    private func bindDeleteRoute(viewModel: ChatViewModel, viewController: UIViewController) {
        viewModel
            .route
            .filter { $0 == .showDeleteTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatDeleteViewModel())
            }
            .filter(Self.filterPrimaryAction)
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatDeleteConfirmationViewModel())
            }
            .filter(Self.filterPrimaryAction)
            .sink { _ in
                viewModel.deleteMessages()
            }
            .store(in: cancelBag)
    }

    private static func filterPrimaryAction(result: RouterResult<BottomActionSheetActionType>) -> Bool {
        if case let .finished(actionType) = result { return actionType == .primary }
        return false
    }
}

extension ChatCoordinator {

    private func showRevealIdentity(router: Router, isUserResponse: Bool) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatIdentityRevealCoordinator(isUserResponse: isUserResponse, router: router, animated: true))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func presentActionSheet<ViewModel: BottomActionSheetViewModelProtocol>(router: Router,
                                                                                   viewModel: ViewModel) -> ActionSheetResult {
        coordinate(to: BottomActionSheetCoordinator(router: router, viewModel: viewModel))
        .flatMap { result -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

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
