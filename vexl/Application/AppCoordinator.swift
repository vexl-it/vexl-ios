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
    private var deeplinkCancellable: AnyCancellable?

    init(window: UIWindow) {
        self.window = window
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
            case .initial:
                return showInitialCoordinator()
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
        deeplinkCancellable?.cancel()
        window.rootViewController = nil
        coordinateToRoot()
        setupDeeplink()
    }

    private func setupDeeplink() {
        deeplinkCancellable = deeplinkManager
            .openDeeplink
            .withUnretained(self)
            .filter { owner, _ in
                owner.initialScreenManager.getCurrentScreenState() == .home && owner.deeplinkManager.canOpenDeepLink
            }
            .flatMapLatest { owner, screen -> CoordinatingResult<RouterResult<Void>> in
                guard let visibleViewController = owner.window.visibleViewController else {
                    return Empty(completeImmediately: false).eraseToAnyPublisher()
                }

                switch screen {
                case .chat(let managedChat):
                    let modalRouter = ModalRouter(parentViewController: visibleViewController, presentationStyle: .fullScreen)
                    return owner.showChat(chat: managedChat, router: modalRouter)
                case .request:
                    let modalRouter = ModalRouter(parentViewController: visibleViewController, presentationStyle: .fullScreen)
                    return owner.showChatRequests(router: modalRouter)
                case .groupInput(let code):
                    let modalNavigationRouter = ModalNavigationRouter(parentViewController: visibleViewController, presentationStyle: .fullScreen)
                    return owner.showGroupsInput(router: modalNavigationRouter, code: code)
                }
            }
            .sink(receiveValue: { [deeplinkManager] _ in
                deeplinkManager.cleanState()
            })
    }
}

extension AppCoordinator {
    private func showSplashCoordinator() -> CoordinatingResult<Void> {
        coordinate(to: SplashScreenCoordinator(window: window))
    }

    private func showInitialCoordinator() -> CoordinatingResult<Void> {
        if UserDefaultsConfig.hasSeenOnboarding {
            return showWelcomeCoordinator()
        } else {
            return showOnboardingCoordinator()
        }
    }

    private func showOnboardingCoordinator() -> CoordinatingResult<Void> {
        coordinate(to:
            WindowNavigationCoordinator(window: window) { router, animated -> OnboardingCoordinator in
                OnboardingCoordinator(router: router, animated: animated)
            }
        )
            .asVoid()
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func showWelcomeCoordinator() -> CoordinatingResult<Void> {
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

// MARK: - Deeplink

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

    private func showChat(chat: ManagedChat, router: Router) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: ChatCoordinator(chat: chat, router: router, animated: true))
            .flatMap { result -> CoordinatingResult<RouterResult<Void>> in
                guard result != .dismissedByRouter else {
                    return Just(result).eraseToAnyPublisher()
                }
                return router.dismiss(animated: true, returning: result)
            }
            .prefix(1)
            .eraseToAnyPublisher()
    }

    private func showGroupsInput(router: Router, code: String) -> CoordinatingResult<RouterResult<Void>> {
        coordinate(to: GroupsInputCoordinator(router: router, animated: true, code: code, fromDeeplink: true))
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
