//
//  NotificationPermissionCoordinator.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.09.2022.
//

import Foundation
import Combine
import Cleevio

class NotificationPermissionCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = NotificationPermissionViewModel()
        let viewController = BaseViewController(rootView: NotificationPermissionView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        // MARK: - ViewModel bindings

        viewModel
            .route
            .receive(on: DispatchQueue.main)
            .filter { $0 == .showAreYouSureDialog }
            .flatMapLatest(with: self) { owner, _ -> ActionSheetResult in
                let router = ModalRouter(parentViewController: viewController,
                                         presentationStyle: .overFullScreen,
                                         transitionStyle: .crossDissolve)
                return owner.presentActionSheet(router: router, viewModel: PermissionActionSheetViewModel())
            }
            .withUnretained(self)
            .sink { data in
                let (owner, result) = data
                switch result {
                case .finished(.primary):
                    owner.openSettings()
                case .finished(.secondary):
                    viewModel.rejectNotifications()
                default:
                    break
                }
            }
            .store(in: cancelBag)

        viewModel
            .route
            .receive(on: DispatchQueue.main)
            .filter { $0 == .openSettings }
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.openSettings()
            })
            .store(in: cancelBag)

        let close = viewModel
            .route
            .filter { $0 == .closeTapped }
            .map { _ in RouterResult<Void>.dismiss }

        let finish = viewModel
            .route
            .filter { $0 == .continueTapped }
            .map { _ in RouterResult<Void>.finished(()) }

        return finish.merge(with: close)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func openSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    }
}

extension NotificationPermissionCoordinator {
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
}
