//
//  UserProfileCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 3/04/22.
//

import Foundation
import Cleevio
import Combine

final class UserProfileCoordinator: BaseCoordinator<Void> {

    private let router: Router
    private let animated: Bool

    init(router: Router, animated: Bool) {
        self.router = router
        self.animated = animated
    }

    override func start() -> CoordinatingResult<Void> {
        let bitcoinViewModel = BitcoinViewModel()
        let viewModel = UserProfileViewModel(bitcoinViewModel: bitcoinViewModel)
        let viewController = BaseViewController(rootView: UserProfileView(viewModel: viewModel))
        router.present(viewController, animated: animated)

        viewModel
            .$error
            .assign(to: &viewController.$error)

        viewModel
            .$isLoading
            .assign(to: &viewController.$isLoading)

        viewModel
            .route
            .receive(on: RunLoop.main)
            .filter { $0 == .selectCurrency }
            .flatMapLatest(with: self) { owner, _ -> CoordinatingResult<RouterResult<Void>> in
                let router = ModalRouter(parentViewController: viewController, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve)
                return owner.presentCurrencySelect(router: router)
            }
            .sink()
            .store(in: cancelBag)

        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
}

extension UserProfileCoordinator {
    private func presentCurrencySelect(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: BottomActionSheetCoordinator(router: router, viewModel: CurrencySelectViewModel()))
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
