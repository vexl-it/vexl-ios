//
//  ModalRouter.swift
//
//  Created by Thành Đỗ Long on 24.03.2021.
//

import UIKit

#if !COCOAPODS
import CleevioCore
#endif

public final class ModalRouter: NSObject, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, DismissHandler {

    // MARK: - Instance Properties

    public unowned let parentViewController: UIViewController
    public let dismissPublisher: ActionSubject<Void> = .init()

    private let presentationStyle: UIModalPresentationStyle
    private let transitionStyle: UIModalTransitionStyle?

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

extension ModalRouter: Router {
    public func present(_ viewController: UIViewController, animated: Bool) {
        viewController.modalPresentationStyle = presentationStyle
        viewController.presentationController?.delegate = self

        if let transitionStyle = transitionStyle {
            viewController.modalTransitionStyle = transitionStyle
        }

        parentViewController.definesPresentationContext = true
        parentViewController.present(viewController,
                                     animated: animated,
                                     completion: nil)

    }

    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        parentViewController.dismiss(animated: animated, completion: completion)
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissPublisher.send()
        dismissPublisher.send(completion: .finished)
    }
}
