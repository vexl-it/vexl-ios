//
//  OnboardingCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//

import Combine
import SwiftUI
import Cleevio

final class OnboardingCoordinator: BaseCoordinator<RouterResult<Void>> {

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
        let viewModel = OnboardingViewModel()
        let viewController = BaseViewController(rootView: OnboardingView(viewModel: viewModel))

        // MARK: Child coordinators

        router.present(viewController, animated: animated)

        // Routing actions

        viewModel
            .route
            .receive(on: RunLoop.main)
            .flatMap { [weak self] routeTo -> CoordinatingResult<RouterResult<Void>> in
                guard let owner = self else {
                    return Just(.dismiss).eraseToAnyPublisher()
                }
                
                switch routeTo {
                case .startLoginFlow:
                    return owner.showLoginFlow(router: owner.router)
                case .startModalFlow:
                    let modalRouter = ModalNavigationRouter(parentViewController: viewController)
                    return owner.showLoginFlow(router: modalRouter)
                }
            }
            .sink(receiveValue: { _ in })
            .store(in: cancelBag)

        // Result

        let dismiss = dismissObservable(with: viewController, dismissHandler: router)
            .receive(on: RunLoop.main)
            .map { _ in RouterResult<Void>.dismissedByRouter }

        return dismiss
            .eraseToAnyPublisher()
    }
}

// swiftlint:disable line_length
private extension OnboardingCoordinator {
    
    /// Inside coodinators we usually have methods to start another coordinator. Parent coordinator should be the responsible of dismissing the child screen so when using coordinate(to:) return a flatMap
    /// for dismiss using the router. E.g.:
    /// Use prefix(1) when you won't stream values between child/parent coordinator. This is to avoid memory leaks.
    /// - Parameter router: Each method should receive the router as a parameter. This is because if you want to be able to interchange between a Modal or a Navigation router, you would need to
    /// change in 2 places. The router that it's send as a paramter to the child coordinator and the dismiss method in the flatMap. To avoid this, we just use the router that was received in the method in the
    ///  first place.
    
    func showLoginFlow(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: LoginCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }

    func showModalFlow(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: LoginCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
