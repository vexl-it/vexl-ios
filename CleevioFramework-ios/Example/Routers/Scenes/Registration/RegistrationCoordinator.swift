//
//  RegistrationCoordinator.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 08.02.2022.
//

import Combine
import SwiftUI
import Cleevio

final class RegistrationCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    deinit {
        print("\(self) DEINIT")
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = RegistrationViewModel()
        let viewController = BaseViewController(rootView: RegistrationView(viewModel: viewModel))

        router.present(viewController, animated: animated)

        let dismiss = viewModel.route
            .receive(on: RunLoop.main)
            .flatMap { route -> CoordinatingResult<RouterResult<Void>> in
                switch route {
                case .dismissTapped:
                    return Just(.dismiss).eraseToAnyPublisher()
                }
            }

        let dismissByRouter = dismissObservable(with: viewController, dismissHandler: router)
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return Publishers.Merge(dismiss, dismissByRouter)
            .eraseToAnyPublisher()
    }
}
