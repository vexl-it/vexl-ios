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
import FirebaseDynamicLinks
import FirebaseRemoteConfig
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
        RemoteConfigManager.setup()

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

    // MARK: - Dynamic link

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let webpageURL = userActivity.webpageURL else { return true }

        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webpageURL) { dynamiclink, error in
            guard error == nil else {
                log.error("⛔️ problem handling Firebase DynamicLink: \(String(describing: error))")
                return
            }

            guard let url = dynamiclink?.url else { return }
            log.info("Opening dynamiclink URL: \(url)")
            @Inject var deeplinkManager: DeeplinkManagerType
            deeplinkManager.handleDeeplink(withURL: url)
        }

        return handled
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        application(app,
                    open: url,
                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                    annotation: "")
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        guard let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)?.url else {
            return false
        }

        @Inject var deeplinkManager: DeeplinkManagerType
        deeplinkManager.handleDeeplink(withURL: dynamicLink)
        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        @Inject var notificationManager: NotificationManagerType
        let typeRawValue: String? = userInfo["type"] as? String
        let type: NotificationType? = typeRawValue.flatMap(NotificationType.init)
        notificationManager.handleNotification(of: type, with: userInfo) { error in
            if error != nil {
                completionHandler(.failed)
            } else {
                completionHandler(.newData)
            }
        }
    }
}
