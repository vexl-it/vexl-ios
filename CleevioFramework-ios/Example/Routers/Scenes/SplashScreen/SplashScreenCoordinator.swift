//
//  SplashScreenCoordinator.swift
//  Cleevio
//
//  Created by Adam Salih on 08.07.2021.
//
//

import SwiftUI
import Cleevio

final class SplashScreenCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow

    deinit {
        print("\(self) DEINIT")
    }

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> CoordinatingResult<CoordinationResult> {
        let viewModel = SplashScreenViewModel()
        let viewController = BaseViewController(rootView: SplashScreenView(viewModel: viewModel))

        window.tap {
            $0.rootViewController = viewController
            $0.makeKeyAndVisible()
        }

        return viewModel
            .route
            .eraseToAnyPublisher()
            .asVoid()
    }
}
