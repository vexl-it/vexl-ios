//
//  BottomActionSheetCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 24.06.2022.
//

import SwiftUI
import Cleevio
import Combine

final class BottomActionSheetCoordinator<ViewModel: BottomActionSheetViewModelProtocol>: BaseCoordinator<RouterResult<Void>> {

    private let router: Router

    private let viewModel: ViewModel

    init(router: Router, viewModel: ViewModel) {
        self.router = router
        self.viewModel = viewModel
    }

    override func start() -> CoordinatingResult<RouterResult<Void>> {
        let viewController = BaseViewController(rootView: BottomActionSheetView(viewModel: viewModel))
        viewController.view.backgroundColor = .clear

        router.present(viewController, animated: true)

        let dismiss = viewModel
            .dismissPublisher
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}
