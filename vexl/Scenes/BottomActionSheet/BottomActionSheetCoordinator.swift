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
}

final class BottomActionSheetCoordinator<ViewModel: BottomActionSheetViewModelProtocol>: BaseCoordinator<RouterResult<Void>> {

    private let router: Router

    private let viewModel: ViewModel

    private var primaryAction = ActionSubject<Void>()
    private var secondaryAction = ActionSubject<Void>()

    init(router: Router, viewModel: ViewModel) {
        self.router = router
        self.viewModel = viewModel
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewController = BaseViewController(rootView: BottomActionSheetView(viewModel: viewModel))
        viewController.view.backgroundColor = .clear

        router.present(viewController, animated: true)

        let primary = viewModel
            .primaryActionPublisher
            .eraseToAnyPublisher()
            .map { _ -> RouterResult<Void> in .finished(()) }

        let secondary = viewModel
            .secondaryActionPublisher
            .eraseToAnyPublisher()
            .map { _ -> RouterResult<Void> in .finished(()) }

        let dismiss = viewModel
            .dismissPublisher
            .map { _ -> RouterResult<Void> in .dismiss }

        return Publishers.Merge3(primary, secondary, dismiss)
            .eraseToAnyPublisher()
    }
}
