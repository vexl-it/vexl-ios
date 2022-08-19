//
//  AppCoordinator.swift
//  CleevioRoutersExample
//
//  Created by Thành Đỗ Long on 14.01.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import Cleevio

final class AppCoordinator: BaseCoordinator<Void> {

    @Inject var initialScreenManager: InitialScreenManager
    @Inject var syncQueue: SyncQueueManagerType
    @Inject var notificationManager: NotificationManagerType
    @Inject var deeplinkManager: DeeplinkManagerType

    private let window: UIWindow
    private let deeplinkWindow: UIWindow

    init(window: UIWindow) {
        self.window = window
        self.deeplinkWindow = window
    }

    override func start() -> CoordinatingResult<Void> {
        coordinateToRoot()
        setupDeeplink()
        return Empty()
            .eraseToAnyPublisher()
    }

    // Recursive method that will restart a child coordinator after completion.
    // Based on:
    // https://github.com/uptechteam/Coordinator-MVVM-Rx-Example/issues/3
    private func coordinateToRoot() {
        let coordinationResult: CoordinatingResult<Void> = {
            switch initialScreenManager.getCurrentScreenState() {
            case .splashScreen:
                return showSplashCoordinator()
            case .welcome:
                return showOnboardingCoordinator()
            case .registerName:
                return showRegisterNameAvatarCoordinator()
            case .registerContacts:
                return showImportPhonesCoordinator()
            case .home:
                return showHomeCoordinator()
            }
        }()

        cancellable = coordinationResult
            .withUnretained(self)
            .sink(receiveValue: { owner, _ in
                owner.resetFlow()
            })
    }

    private func resetFlow() {
        cancellable?.cancel()
        window.rootViewController = nil
        coordinateToRoot()
    }

    private func setupDeeplink() {
        deeplinkManager
            .openDeeplink // filter if it's logged in?
            .flatMapLatest(with: self) { owner, type -> CoordinatingResult<RouterResult<Void>> in
                switch type {
                case .openChat:
                    let modalRouter = ModalRouter(parentViewController: owner.window.visibleViewController!, presentationStyle: .fullScreen)
                    return owner.showChatRequests(router: modalRouter)
                case .openRequest:
                    let modalRouter = ModalRouter(parentViewController: owner.window.visibleViewController!, presentationStyle: .fullScreen)
                    return owner.showChatRequests(router: modalRouter)
                case .openInbox:
                    return Empty(completeImmediately: false).eraseToAnyPublisher()
                }
            }
            .sink()
            .store(in: cancelBag)
    }
}

extension AppCoordinator {
    private func showChatRequests(router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatRequestCoordinator(router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func showSplashCoordinator() -> CoordinatingResult<Void> {
        coordinate(to: SplashScreenCoordinator(window: window))
    }

    private func showOnboardingCoordinator() -> CoordinatingResult<Void> {
        coordinate(to:
            WindowNavigationCoordinator(window: window) { router, animated -> WelcomeCoordinator in
                WelcomeCoordinator(router: router, animated: animated)
            }
        )
            .asVoid()
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func showRegisterNameAvatarCoordinator() -> CoordinatingResult<Void> {
        coordinate(to:
            WindowNavigationCoordinator(window: window) { router, animated -> RegisterNameAvatarCoordinator in
                RegisterNameAvatarCoordinator(router: router, animated: animated)
            }
        )
            .asVoid()
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func showImportPhonesCoordinator() -> CoordinatingResult<Void> {
        coordinate(to:
            WindowNavigationCoordinator(window: window) { router, animated -> RegisterPhoneContactsCoordinator in
                RegisterPhoneContactsCoordinator(router: router, animated: animated)
            }
        )
            .asVoid()
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func showHomeCoordinator() -> CoordinatingResult<Void> {
        coordinate(to: TabBarCoordinator(window: window))
            .prefix(1)
            .eraseToAnyPublisher()
    }
}

extension UIWindow {
    var visibleViewController: UIViewController? {
        UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
