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

    private let router: Router
    private let animated: Bool
    private let chat: ManagedChat

    init(chat: ManagedChat, router: Router, animated: Bool) {
        self.chat = chat
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = ChatViewModel(chat: chat)
        let viewController = BaseViewController(rootView: ChatView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        bindDeleteRoute(viewModel: viewModel, viewController: viewController)
        bindBlockRoute(viewModel: viewModel, viewController: viewController)
        bindRevealIdentity(viewModel: viewModel, viewController: viewController)

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
            .compactMap { action -> ManagedOffer? in
                if case let .showOfferTapped(offer) = action { return offer }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, offer -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatOfferSheetViewModel(offer: offer))
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
                return owner.presentActionSheet(router: router, viewModel: ChatDeleteSheetViewModel(isConfirmation: false))
            }
            .filter(Self.filterPrimaryAction)
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatDeleteSheetViewModel(isConfirmation: true))
            }
            .filter(Self.filterPrimaryAction)
            .sink { _ in
                viewModel.deleteMessages()
            }
            .store(in: cancelBag)
    }

    private func bindBlockRoute(viewModel: ChatViewModel, viewController: UIViewController) {
        viewModel
            .route
            .filter { $0 == .showBlockTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatBlockSheetViewModel(isConfirmation: false))
            }
            .filter { result in
                if case let .finished(actionType) = result { return actionType == .primary }
                return false
            }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatBlockSheetViewModel(isConfirmation: true))
            }
            .filter { result in
                if case let .finished(actionType) = result { return actionType == .primary }
                return false
            }
            .sink { _ in
                viewModel.blockMessages()
            }
            .store(in: cancelBag)
    }

    private func bindRevealIdentity(viewModel: ChatViewModel, viewController: UIViewController) {
        viewModel
            .route
            .filter { $0 == .showRevealIdentityTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ChatIdentitySheetViewModel(isResponse: false))
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
                return owner.presentActionSheet(router: router, viewModel: ChatIdentitySheetViewModel(isResponse: true))
            }
            .compactMap { result -> BottomActionSheetActionType? in
                if case let .finished(actionType) = result { return actionType }
                return nil
            }
            .sink { action in
                viewModel.identityRevealResponse(isAccepted: action == .primary)
            }
            .store(in: cancelBag)

        viewModel
            .route
            .compactMap { action -> (isResponse: Bool, username: String, avatar: String?)? in
                if case let .showRevealIdentityModal(isUserResponse, username, avatar) = action {
                    return (isResponse: isUserResponse, username: username, avatar: avatar)
                }
                return nil
            }
            .withUnretained(self)
            .flatMap { owner, response -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .coverVertical)
                return owner.showRevealIdentity(router: router,
                                                isUserResponse: response.isResponse,
                                                username: response.username,
                                                avatar: response.avatar)
            }
            .sink()
            .store(in: cancelBag)
    }

    private static func filterPrimaryAction(result: RouterResult<BottomActionSheetActionType>) -> Bool {
        if case let .finished(actionType) = result { return actionType == .primary }
        return false
    }
}

extension ChatCoordinator {

    private func showRevealIdentity(router: Router,
                                    isUserResponse: Bool,
                                    username: String,
                                    avatar: String?) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatIdentityRevealCoordinator(isUserResponse: isUserResponse,
                                                     username: username,
                                                     avatar: avatar,
                                                     router: router,
                                                     animated: true))
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
