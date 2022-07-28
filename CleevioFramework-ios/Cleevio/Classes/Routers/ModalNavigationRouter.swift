//
//  ModalRouter.swift
//  pilulka
//
//  Created by Thành Đỗ Long on 24.03.2021.
//

import UIKit

#if !COCOAPODS
import CleevioCore
#endif

public final class ModalNavigationRouter: NSObject, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, DismissHandler {

    // MARK: - Instance Properties

    public unowned let parentViewController: UIViewController

    private let navigationController = UINavigationController()
    private let presentationStyle: UIModalPresentationStyle
    private let transitionStyle: UIModalTransitionStyle?
    public let dismissPublisher: ActionSubject<Void> = .init()

    // MARK: - Object Lifecycle

    public init(parentViewController: UIViewController,
                presentationStyle: UIModalPresentationStyle = .automatic,
                transitionStyle: UIModalTransitionStyle? = nil) {
        self.parentViewController = parentViewController
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
    }
}

// MARK: - Router

extension ModalNavigationRouter: Router {
    public enum Action {
        /// Pop in the stack.
        case pop(NavigationRouter.PopAction)
        /// Dismisses the most recently presented screen.
        case dismiss
    }

    public func present(_ viewController: UIViewController, animated: Bool) {
        navigationController.modalPresentationStyle = presentationStyle
        navigationController.presentationController?.delegate = self

        if let transitionStyle = transitionStyle {
            viewController.modalTransitionStyle = transitionStyle
        }

        if navigationController.viewControllers.isEmpty {
            presentModally(viewController, animated: animated)
        } else {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }

    private func presentModally(_ viewController: UIViewController, animated: Bool) {
        navigationController.setViewControllers([viewController], animated: false)
        parentViewController.present(navigationController,
                                     animated: animated,
                                     completion: nil)
    }

    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        if navigationController.visibleViewController == navigationController.viewControllers.first {
            perform(.dismiss, animated: animated, completion: completion)
        } else {
            perform(.pop(.toParent), animated: animated, completion: completion)
        }
    }

    public func perform(_ action: Action, animated: Bool, completion: (() -> Void)? = nil) {
        switch action {
        case .pop(.toViewController(let viewController)):
            navigationController.popToViewController(viewController, animated: animated)
        case .pop(.toRoot):
            navigationController.popToRootViewController(animated: animated)
        case .pop(.toParent):
            navigationController.popViewController(animated: animated)
        case .dismiss:
            parentViewController.dismiss(animated: animated, completion: { [weak self] in
                self?.navigationController.viewControllers = []
            })
        }

        completion?()
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        navigationController.viewControllers = []
        
        dismissPublisher.send()
        dismissPublisher.send(completion: .finished)
    }
}
