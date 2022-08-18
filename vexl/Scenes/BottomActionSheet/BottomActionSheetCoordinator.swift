//
//  BottomActionSheetCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Cleevio
import Combine

typealias BottonActionSheetRouterResult = RouterResult<BottomActionSheetActionType>

enum BottomActionSheetActionType {
    case primary
    case secondary
    case contentAction
}

final class BottomActionSheetCoordinator<ViewModel: BottomActionSheetViewModelProtocol>: BaseCoordinator<RouterResult<BottomActionSheetActionType>> {

    private let router: Router

    private let viewModel: ViewModel

    init(router: Router, viewModel: ViewModel) {
        self.router = router
        self.viewModel = viewModel
    }

    override func start() -> CoordinatingResult<RouterResult<BottomActionSheetActionType>> {
        let viewController = BaseViewController(rootView: BottomActionSheetView(viewModel: viewModel))
        viewController.view.backgroundColor = .clear

        router.present(viewController, animated: true)

        let action = viewModel
            .actionPublisher
            .eraseToAnyPublisher()
            .map { type -> RouterResult<BottomActionSheetActionType> in .finished(type) }

        let dismiss = viewModel
            .dismissPublisher
            .map { _ -> RouterResult<BottomActionSheetActionType> in .dismiss }

        return Publishers.Merge(action, dismiss)
            .eraseToAnyPublisher()
    }
}
