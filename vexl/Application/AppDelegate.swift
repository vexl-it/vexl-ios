//
//  AppDelegate.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import UIKit
import SwiftyBeaver
import FBSDKCoreKit
import Firebase
import FirebaseMessaging
#if DEBUG || DEVEL
import AlamofireNetworkActivityLogger
#endif

let log = SwiftyBeaver.self

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        #if DEBUG || DEVEL
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
        whereIsMySQLite()
        #endif

        // Firebase messaging
        FirebaseApp.configure()

        // Global appearance
        Appearance.setGlobalAppearance()
        return true
    }

    func whereIsMySQLite() {
        let path = FileManager
            .default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .last?
            .absoluteString
            .replacingOccurrences(of: "file://", with: "")
            .removingPercentEncoding

        log.addDestination(ConsoleDestination())
        log.debug("db path: \(path ?? "Not found")", context: nil)
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after
        // application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
