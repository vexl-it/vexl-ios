//
//  ModalNavigationRouter.swift
//
//  Created by Thành Đỗ Long on 17.03.2021.
//

import UIKit
import SwiftUI

#if !COCOAPODS
import CleevioCore
#endif

public final class NavigationRouter: NSObject, DismissHandler {
    public enum NavigationAnimation {
        case easeInEaseOut
        case `default`
    }

    private let navigationController: UINavigationController
    private var routerRootController: UIViewController?
    private var animation: NavigationAnimation
    public let dismissPublisher: ActionSubject<Void> = .init()

    public init(navigationController: UINavigationController, animation: NavigationAnimation = .default) {
        self.navigationController = navigationController
        self.animation = animation
        self.routerRootController = navigationController.viewControllers.first
    }

    public func setRootController(_ viewController: UIViewController) {
        guard let viewController = navigationController.viewControllers.first(where: { $0 === viewController }) else { return }
        routerRootController = viewController
    }
}

// MARK: - Router

extension NavigationRouter: Router {
    public enum PopAction {
        /// Goes back to the very first screen in the stack.
        case toRoot
        /// Goes back to a specific screen in the stack.
        case toViewController(UIViewController)
        /// Goes back one screen in the stack.
        case toParent
    }

    public func present(_ viewController: UIViewController, animated: Bool) {
        switch animation {
        case .easeInEaseOut where animated == true:
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade
            navigationController.view.layer.add(transition, forKey: nil)

            navigationController.pushViewController(viewController, animated: false)
        default:
            navigationController.pushViewController(viewController, animated: animated)
        }
    }

    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        perform(.toParent, animated: animated, completion: completion)
        routerRootController = navigationController.viewControllers.first
    }

    public func perform(_ popAction: PopAction, animated: Bool, completion: (() -> Void)? = nil) {
        var animated = animated

        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
        }

        switch animation {
        case .easeInEaseOut where animated == true:
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade
            animated = false
            navigationController.view.layer.add(transition, forKey: nil)
        default:
            break
        }

        switch popAction {
        case .toViewController(let viewController):
            navigationController.popToViewController(viewController, animated: animated)
        case .toRoot:
            navigationController.popToRootViewController(animated: animated)
        case .toParent:
            navigationController.popViewController(animated: animated)
        }

        if animated {
            CATransaction.commit()
        } else {
            completion?()
        }
    }
}
