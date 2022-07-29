//
//  AppDelegateRouter.swift
//  Cleevio
//
//  Created by Thành Đỗ Long on 14.01.2022.
//

import UIKit

#if !COCOAPODS
import CleevioCore
#endif

open class AppDelegateRouter: Router {

    // MARK: - Instance Properties

    public let window: UIWindow
    public var dismissPublisher = ActionSubject<Void>()

    // MARK: - Object Lifecycle

    public init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Router
    public func present(_ viewController: UIViewController, animated: Bool) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        // don't do anything
    }
}
