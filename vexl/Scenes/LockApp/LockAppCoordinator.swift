//
//  LockAppCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 23/09/22.
//

import Foundation
import Cleevio
import Combine

final class LockAppCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let style: LockAppViewModel.Style
    private let router: Router
    private let animated: Bool

    init(style: LockAppViewModel.Style, router: Router, animated: Bool) {
        self.style = style
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = LockAppViewModel(style: style)
        let viewController = BaseViewController(rootView: LockAppView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}
