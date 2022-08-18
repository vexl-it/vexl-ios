//
//  TermsAndConditionsCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 6/08/22.
//

import Foundation
import Combine
import Cleevio

final class TermsAndConditionsCoordinator: BaseCoordinator<RouterResult<Void>> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = TermsAndConditionsViewModel()
        let viewController = BaseViewController(rootView: TermsAndConditionsView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .route
            .filter { $0 == .faqTapped }
            .withUnretained(self)
            .flatMap { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen)
                return owner.showFAQ(router: router)
            }
            .sink()
            .store(in: cancelBag)

        let dismiss = viewModel
            .route
            .filter { $0 == .dismissTapped }
            .map { _ -> RouterResult<Void> in .dismiss }

        return dismiss
            .eraseToAnyPublisher()
    }
}

extension TermsAndConditionsCoordinator {
    func showFAQ(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: FAQCoordinator(router: router, animated: true))
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
