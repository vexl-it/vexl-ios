//
//  SceneDelegate.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let disposeBag = DisposeBag()
    private var appCoordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        appCoordinator = AppCoordinator(window: window!)
        startApplication()
    }

    private func startApplication() {
        appCoordinator
            .start()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
