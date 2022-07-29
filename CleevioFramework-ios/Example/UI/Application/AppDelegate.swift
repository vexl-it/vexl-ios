//
//  AppDelegate.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import UIKit


typealias NotificationPayload = [AnyHashable: Any]
typealias FetchCompletion = (UIBackgroundFetchResult) -> Void

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var systemEventsHandler: SystemEventsHandler? = {
        self.systemEventsHandler(UIApplication.shared)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Appearance.setupTransparentNavBar()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func systemEventsHandler(_ application: UIApplication) -> SystemEventsHandler? {
        return sceneDelegate(application)?.systemEventsHandler
    }


    private func sceneDelegate(_ application: UIApplication) -> SceneDelegate? {
        return application.windows
            .compactMap({ $0.windowScene?.delegate as? SceneDelegate })
            .first
    }
}

