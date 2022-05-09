//
//  MarketplaceCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import UIKit
import Cleevio
import SwiftUI
import Combine

//final class CoinValueCoordinator: BaseCoordinator<Void> {
//
//    private let router: Router
//    private let animated: Bool
//    private let tab: HomeTab
//
//    init(router: Router, tab: HomeTab, animated: Bool) {
//        self.router = router
//        self.animated = animated
//        self.tab = tab
//    }
//
//    override func start() -> CoordinatingResult<Void> {
//        Just(router)
//            .withUnretained(self)
//            .flatMap { owner, router -> CoordinatingResult<RouterResult<Void>> in
//                switch owner.tab {
//                case .marketplace:
//                    return owner.showMarketplace(router: router)
//                case .profile:
//                    return owner.showProfile(router: router)
//                }
//            }
//            .sink { _ in }
//            .store(in: cancelBag)
//
//        return Empty(completeImmediately: false)
//            .eraseToAnyPublisher()
//    }
//}
//
//extension CoinValueCoordinator {
//
//    private func showMarketplace(router: Router) -> CoordinatingResult<RouterResult<Void>> {
//        coordinate(to: MarketplaceCoordinator(router: router, animated: true))
//            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
//                guard result != .dismissedByRouter else {
//                    return Just(result).eraseToAnyPublisher()
//                }
//                return router.dismiss(animated: true, returning: result)
//            }
//            .prefix(1)
//            .eraseToAnyPublisher()
//    }
//
//    private func showProfile(router: Router) -> CoordinatingResult<RouterResult<Void>> {
//        coordinate(to: UserProfileCoordinator(router: router, animated: true))
//            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
//                guard result != .dismissedByRouter else {
//                    return Just(result).eraseToAnyPublisher()
//                }
//                return router.dismiss(animated: true, returning: result)
//            }
//            .prefix(1)
//            .eraseToAnyPublisher()
//    }
//}
//
//final class CoinValueWindowCoordinator: BaseCoordinator<Void> {
//
//    private let homeViewController: CoinValueViewController
//    private let homeViewModel: CoinValueViewModel
//    private let homeRouter: CoinValueRouter
//    private let window: UIWindow
//
//    init(window: UIWindow) {
//        self.homeViewModel = CoinValueViewModel()
//        self.homeViewController = CoinValueViewController(viewModel: homeViewModel)
//        self.homeRouter = CoinValueRouter(homeViewController: homeViewController)
//        self.window = window
//    }
//
//    override func start() -> CoordinatingResult<Void> {
//        window.tap {
//            $0.rootViewController = homeViewController
//            $0.makeKeyAndVisible()
//        }
//
//        // Setting initial child view controller
//
//        Just(homeRouter)
//            .withUnretained(self)
//            .flatMap { owner, router in
//                owner.showMarketplaceAsRoot(router: router)
//            }
//            .sink { _ in }
//            .store(in: cancelBag)
//
//        UIView.transition(
//            with: window,
//            duration: 0.5,
//            options: .transitionCrossDissolve,
//            animations: nil,
//            completion: nil
//        )
//
//        return Empty(completeImmediately: false)
//            .eraseToAnyPublisher()
//    }
//}
//
//extension CoinValueWindowCoordinator {
//    private func showMarketplaceAsRoot(router: Router) -> CoordinatingResult<RouterResult<Void>> {
//        coordinate(to: MarketplaceCoordinator(router: router, animated: true))
//            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
//                guard result != .dismissedByRouter else {
//                    return Just(result).eraseToAnyPublisher()
//                }
//                return router.dismiss(animated: true, returning: result)
//            }
//            .prefix(1)
//            .eraseToAnyPublisher()
//    }
//}
