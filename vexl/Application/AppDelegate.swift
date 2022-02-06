//
//  AppDelegate.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import UIKit
import RxSwift
import AlamofireNetworkActivityIndicator
import SwiftyBeaver
import Firebase

#if DEBUG
import AlamofireNetworkActivityLogger
#endif

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase
        if NSClassFromString("XCTest") != nil {
            return true
        } else {
            FirebaseApp.configure()
        }

        // SwiftyBeaver
        let console = ConsoleDestination()  // log to Xcode Console
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        log.addDestination(console)

        // Global appearance
        Appearance.setGlobalAppearance()

        NetworkActivityIndicatorManager.shared.isEnabled = true

        #if DEBUG
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
        #endif

        setupLoggingResources()

        return true
    }

    private func setupLoggingResources() {
        #if DEBUG
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { _ in RxSwift.Resources.total }
            .distinctUntilChanged()
            .subscribe(onNext: { count in
                log.debug("RxSwift Resources count = \(count)")
            })
            .disposed(by: disposeBag)
        #endif
    }
}
