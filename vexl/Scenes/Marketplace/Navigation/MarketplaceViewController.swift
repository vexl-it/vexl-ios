//
//  MarketplaceCoordinator.swift
//  vexl
//
//  Created by Diego Espinoza on 14/04/22.
//

import Foundation
import UIKit
import Cleevio

final class MarketplaceViewController: UIViewController {

    let dismissPublisher: ActionSubject<Void> = .init()

    var topViewController: UIViewController?
    var bottomViewController: UIViewController?
    var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    func set(topViewController: UIViewController) {
        self.topViewController = topViewController
        addChild(topViewController)
        let childView = topViewController.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: view.topAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if let bottomChildView = bottomViewController?.view {
            bottomChildView.topAnchor.constraint(equalTo: childView.bottomAnchor).isActive = true
        }

        topViewController.didMove(toParent: self)
    }

    func set(bottomViewController: UIViewController) {
        self.bottomViewController = bottomViewController
        addChild(bottomViewController)
        let childView = bottomViewController.view!
        childView.backgroundColor = R.color.green1()
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if let topChildView = topViewController?.view {
            topChildView.bottomAnchor.constraint(equalTo: childView.topAnchor).isActive = true
        }

        bottomViewController.didMove(toParent: self)
    }

    func present(childViewController: UIViewController) {
        guard let bottomView = bottomViewController?.view else {
            return
        }

        self.currentViewController = childViewController
        addChild(childViewController)
        let childView = childViewController.view!
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            childView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor)
        ])

        childView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        childView.alpha = 0.25

        childViewController.didMove(toParent: childViewController)

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.75, options: .curveEaseInOut) {
            childView.transform = CGAffineTransform.identity
            childView.alpha = 1
        }
    }

    func dismiss() {
        guard let currentViewController = currentViewController else {
            return
        }

        let childView = currentViewController.view!

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.75, options: .curveEaseInOut) {
            childView.transform = CGAffineTransform(translationX: 0, y: childView.bounds.height)
            childView.alpha = 0.25
        } completion: { [weak self] _ in
            currentViewController.removeFromParent()
            childView.removeFromSuperview()
            currentViewController.didMove(toParent: nil)
            self?.currentViewController = nil
        }
    }
}

// TODO: - remove this

class TestViewController: UIViewController {

    var dismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)

        let l = UILabel()
        l.text = "GOO"
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(l)
        NSLayoutConstraint.activate([
            l.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            l.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc
    private func tap() {
        dismiss?()
    }
}
