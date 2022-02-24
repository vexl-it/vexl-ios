//
//  RegisterPhoneCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import Foundation
import Combine
import Cleevio

class RegisterPhoneCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = RegisterPhoneViewModel()
        let viewController = BaseViewController(rootView: RegisterPhoneView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        let next = viewModel.route
            .filter { $0 == .continueTapped }
            .map { _ -> RouterResult<Void> in .finished(()) }

        return next
            .receive(on: RunLoop.main)
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
