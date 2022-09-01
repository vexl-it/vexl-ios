//
//  UserProfileCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import Cleevio
import Combine

private typealias ActionSheetResult = CoordinatingResult<RouterResult<BottomActionSheetActionType>>

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
        let viewController = UserProfileViewController(rootView: UserProfileView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        bindDeleteAccount(viewModel: viewModel, viewController: viewController)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .faq }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen, transitionStyle: .coverVertical)
                return owner.showFAQ(router: router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .termsAndPrivacy }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen, transitionStyle: .coverVertical)
                return owner.showTermsAndConditions(router: router)
            }
            .sink()
            .store(in: cancelBag)

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
            .filter { $0 == .importFacebook }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .fullScreen, transitionStyle: .coverVertical)
                let coordinator = ProfileFacebookContactsCoordinator(router: router, animated: true)
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

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .reportIssue }
            .flatMapLatest(with: self) { owner, _ -> ActionSheetResult in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: ReportIssueSheetViewModel())
            }
            .filter { result in
                if case let .finished(actionType) = result { return actionType == .contentAction }
                return false
            }
            .sink { _ in
                viewController.presentEmailComposer()
            }
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .showGroups }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalNavigationRouter(
                    parentViewController: viewController,
                    presentationStyle: .fullScreen,
                    transitionStyle: .coverVertical
                )
                let coordinator = GroupsCoordinator(router: router, animated: true)
                return owner.present(coordinator: coordinator, router: router)
            }
            .sink()
            .store(in: cancelBag)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }

    private func bindDeleteAccount(viewModel: UserProfileViewModel, viewController: UIViewController) {
        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .deleteAccount }
            .flatMapLatest(with: self) { owner, _ -> ActionSheetResult in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: DeleteAccountSheetViewModel(isConfirmation: false))
            }
            .filter { result in
                if case let .finished(actionType) = result { return actionType == .primary }
                return false
            }
            .flatMapLatest(with: self) { owner, _ -> ActionSheetResult in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: DeleteAccountSheetViewModel(isConfirmation: true))
            }
            .filter { result in
                if case let .finished(actionType) = result { return actionType == .primary }
                return false
            }
            .sink { _ in
                viewModel.logoutUser()
            }
            .store(in: cancelBag)
    }
}

extension UserProfileCoordinator {

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

    private func presentCurrencySelect(router: Router) -> ActionSheetResult {
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

    private func presentDonate(router: Router) -> ActionSheetResult {
        coordinate(to: BottomActionSheetCoordinator(router: router, viewModel: DonateViewModel()))
        .flatMap { result -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .handleEvents(receiveOutput: { result in
            guard case .finished(let action) = result, action == .primary else { return }
            if let url = URL(string: L.userProfileDonateButtonDonateUrl()) {
                UIApplication.shared.open(url)
            }
        })
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func presentJoinVexl(router: Router) -> ActionSheetResult {
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

    private func presentGroups(router: Router) -> ActionSheetResult {
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

    func showTermsAndConditions(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: TermsAndConditionsCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                switch result {
                case .dismiss:
                    return router.dismiss(animated: true, returning: result)
                case .finished, .dismissedByRouter:
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }

    func showFAQ(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: FAQCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                switch result {
                case .dismiss:
                    return router.dismiss(animated: true, returning: result)
                case .finished, .dismissedByRouter:
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
