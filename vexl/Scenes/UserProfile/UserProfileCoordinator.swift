//
//  UserProfileCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import Cleevio
import Combine

final class UserProfileCoordinator: BaseCoordinator<Void> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {
        let bitcoinViewModel = BitcoinViewModel()
        let viewModel = UserProfileViewModel(bitcoinViewModel: bitcoinViewModel)
        let viewController = BaseViewController(rootView: UserProfileView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .selectCurrency }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve)
                return owner.presentCurrencySelect(router: router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .joinVexl }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve)
                return owner.presentJoinVexl(router: router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .editName }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen, transitionStyle: .coverVertical)
                let coordinator = EditProfileNameCoordinator(router: router, animated: true)
                return owner.present(coordinator: coordinator, router: router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .importContacts }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen, transitionStyle: .coverVertical)
                let coordinator = ProfilePhoneContactsCoordinator(router: router, animated: true)
                return owner.present(coordinator: coordinator, router: router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .editAvatar }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen, transitionStyle: .coverVertical)
                let coordinator = EditProfileAvatarCoordinator(router: router, animated: true)
                return owner.present(coordinator: coordinator, router: router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .donate }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve)
                return owner.presentDonate(router: router)
            }
            .sink()
            .store(in: cancelBag)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}

extension UserProfileCoordinator {

    private func present(coordinator: BaseCoordinator<RouterResult<Void>>, router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: coordinator)
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func presentCurrencySelect(router: Router) -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> {
        coordinate(to: BottomActionSheetCoordinator(router: router, viewModel: CurrencySelectViewModel()))
        .flatMap { result -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func presentDonate(router: Router) -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> {
        coordinate(to: BottomActionSheetCoordinator(router: router, viewModel: DonateViewModel()))
        .flatMap { result -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func presentJoinVexl(router: Router) -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> {
        coordinate(to: BottomActionSheetCoordinator(router: router, viewModel: JoinVexlViewModel()))
        .flatMap { result -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }
}
