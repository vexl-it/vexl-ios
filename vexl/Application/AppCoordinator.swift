//
//  AppCoordinator.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit
import RxSwift

final class AppCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<Void> {
        coordinateToRoot()
        return Observable.never()
    }

    // Recursive method that will restart a child coordinator after completion.
    // Based on:
    // https://github.com/uptechteam/Coordinator-MVVM-Rx-Example/issues/3
    private func coordinateToRoot() {
        showTest()
            .subscribe(onNext: { [weak self] _ in
                self?.window.rootViewController = nil
                self?.coordinateToRoot()
            })
            .disposed(by: disposeBag)
    }

    private func showTest() -> Observable<Void> {
        let coordinator = TestCoordinator(window: window)
        return coordinate(to: coordinator)
    }
}
