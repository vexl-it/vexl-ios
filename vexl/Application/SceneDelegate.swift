//
//  SceneDelegate.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import UIKit
import Cleevio
import FBSDKCoreKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator!
    private let cancelBag = CancelBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)

        // AppCoordinator
        appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
            .sink(receiveValue: {})
            .store(in: cancelBag)

        self.window = window
        
        // Dynamic Links

        if let userActivity = connectionOptions.userActivities.first {
            if let incomingURL = userActivity.webpageURL {
                DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                    guard error == nil else { return }
                    if let dynamicLink = dynamicLink {
                        if let url = dynamicLink.url {
                            @Inject var deeplinkManager: DeeplinkManagerType
                            deeplinkManager.handleDeeplink(withURL: url)
                        }
                    }
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(UIApplication.shared,
                                               open: url,
                                               sourceApplication: nil,
                                               annotation: [UIApplication.OpenURLOptionsKey.annotation])

        @Inject var deeplinkManager: DeeplinkManagerType
        deeplinkManager.handleDeeplink(withURL: url)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let webpageURL = userActivity.webpageURL else { return }

        DynamicLinks.dynamicLinks().handleUniversalLink(webpageURL) { dynamiclink, error in
            guard error == nil else {
                log.error("⛔️ problem handling Firebase DynamicLink: \(String(describing: error))")
                return
            }

            guard let url = dynamiclink?.url else { return }
            log.info("Opening dynamiclink URL: \(url)")
            @Inject var deeplinkManager: DeeplinkManagerType
            deeplinkManager.handleDeeplink(withURL: url)
        }
    }
}
