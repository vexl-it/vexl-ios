//
//  GroupsCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 01.08.2022.
//

import Foundation
import Cleevio
import Combine

final class GroupsCoordinator: BaseCoordinator<RouterResult<Void>> {

    let animated: Bool
    let router: Router

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {

        let viewModel = GroupsViewModel()
        let viewController = GroupViewController(rootView: GroupsView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        viewModel
            .route
            .filter { $0 == .joinGroupTapped }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.presentGroupScanQR(router: owner.router)
            }
            .sink()
            .store(in: cancelBag)

        viewModel
            .route
            .compactMap { route -> ManagedGroup? in
                guard case let .leaveGroupTapped(group) = route else {
                    return nil
                }
                return group
            }
            .withUnretained(self)
            .flatMap { owner, group -> AnyPublisher<ManagedGroup, Never> in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentGroupLeaveActionSheet(router: router)
                    .compactMap(\.value)
                    .compactMap { result in
                        switch result {
                        case .primary:
                            return group
                        case .secondary, .contentAction:
                            return nil
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .sink(receiveValue: { group in
                viewModel.leave(group: group)
            })
            .store(in: cancelBag)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}

extension GroupsCoordinator {
    private func presentGroupScanQR(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: GroupsScanQRCoordinator(router: router, animated: true))
        .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
            guard result != .dismissedByRouter else {
                return Just(result).eraseToAnyPublisher()
            }
            return router.dismiss(animated: true, returning: result)
        }
        .prefix(1)
        .eraseToAnyPublisher()
    }

    private func presentGroupLeaveActionSheet(router: Router) -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> {
        coordinate(to: BottomActionSheetCoordinator(router: router, viewModel: GroupsLeaveSheetViewModel()))
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
