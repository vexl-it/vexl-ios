//
//  TestCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit
import RxSwift

final class TestCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<CoordinationResult> {
        let viewController = TestViewController.create()
        let navigationController = SwipeNavigationController(rootViewController: viewController)
        let viewModel = viewController.attach(wrapper: ViewModelWrapper<TestViewModel>())

        window.tap {
            $0.rootViewController = navigationController
            $0.makeKeyAndVisible()
        }

        // TODO: Handle return type
        return Observable.never()
    }
}
