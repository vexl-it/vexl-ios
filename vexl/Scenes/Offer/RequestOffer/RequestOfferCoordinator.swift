//
//  RequestOfferCoordinator.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 26.05.2022.
//

import Foundation
import Cleevio
import Combine

final class RequestOfferCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let offer: ManagedOffer

    init(router: Router, offer: ManagedOffer) {
        self.router = router
        self.offer = offer
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewModel = RequestOfferViewModel(offer: offer)
        let viewController = ToggleKeyboardHostingController(rootView: RequestOfferView(viewModel: viewModel))

        router.present(viewController, animated: true)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        let flagPopUps = viewModel.route
            .filter { $0 == .flagTapped }
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.presentActionSheet(
                    router: ModalRouter(
                        parentViewController: viewController,
                        presentationStyle: .overFullScreen,
                        transitionStyle: .crossDissolve
                    ),
                    viewModel: OfferFlagBottomActionSheetViewModel()
                )
            }
            .filter { result in
                guard case let .finished(action) = result, action == .primary else {
                    return false
                }
                return true
            }
            .withUnretained(self)
            .flatMap { [viewController] owner, _ in
                owner.presentActionSheet(
                    router: ModalRouter(
                        parentViewController: viewController,
                        presentationStyle: .overFullScreen,
                        transitionStyle: .crossDissolve
                    ),
                    viewModel: OfferFlagConfirmationActionSheetViewModel()
                )
            }

        let offerFlagged = flagPopUps
            .withUnretained(viewModel)
            .flatMap { viewModel, _ in
                viewModel
                    .flagOffer()
                    .nilOnError()
                    .filterNil()
            }
            .map { () -> RouterResult<Void> in .dismiss }

        let dismiss = viewModel.route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        let requestSent = viewModel.route
            .filter { $0 == .requestSent }
            .map { _ -> RouterResult<Void> in .finished(()) }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .dismissedByRouter(type: Void.self)

        return Publishers.Merge4(requestSent, dismiss, dismissByRouter, offerFlagged)
            .prefix(1)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension RequestOfferCoordinator {
    private func presentActionSheet<ViewModel: BottomActionSheetViewModelProtocol>(
        router: Router,
        viewModel: ViewModel
    ) -> ActionSheetResult {
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
