//
//  LoginCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 07.02.2022.
//

import Combine
import SwiftUI
import Cleevio

private typealias ActionSheetResult = CoordinatingResult<RouterResult<BottomActionSheetActionType>>

final class WelcomeCoordinator: BaseCoordinator<RouterResult<Void>> {

    let publisher = PassthroughSubject<String, Never>()
    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = WelcomeViewModel()
        let viewController = WelcomeViewController(rootView: WelcomeView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .route
            .filter { $0 == .termsAndConditionsTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen)
                return owner.showTermsAndConditions(router: router)
            }
            .sink()
            .store(in: cancelBag)

        let finished = viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .continueTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                owner.showRegisterPhone(router: owner.router)
            }
            .filter { if case .finished = $0 { return true } else { return false } }

        // MARK: Dismiss

        return finished
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

private extension WelcomeCoordinator {
    func showTermsAndConditions(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: TermsAndConditionsCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                switch result {
                case .dismiss:
                    return router.dismiss(animated: true, returning: result)
                case .finished, .dismissedByRouter:
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }

    func showRegisterPhone(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: RegisterPhoneCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                switch result {
                case .dismiss:
                    return router.dismiss(animated: true, returning: result)
                case .finished, .dismissedByRouter:
                    return Just(result).eraseToAnyPublisher()
                }
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }
}
