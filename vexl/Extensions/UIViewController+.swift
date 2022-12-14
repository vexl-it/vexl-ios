//
//  UIViewController+.swift
//  vexl
//
//  Created by Adam Salih on 05.02.2022.
//  
//

import UIKit

extension UIViewController {
    var isVisible: Bool { view.window != nil }

    func presentAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach(alertController.addAction(_:))
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentError(title: String?, onDismiss: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: L.generalOk(), style: .cancel) { _ in
            onDismiss()
        }
        alertController.addAction(dismissAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true)
        }
    }
}

// MARK: - Show message

class PassTroughWindow: UIWindow {
    var passTroughTag: Int?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let hitView = super.hitTest(point, with: event)

        if let passTroughTag = passTroughTag {
            if passTroughTag == hitView?.tag {
                return nil
            }
        }
        return hitView
    }
}


extension UIViewController {
    func showMessage(_ message: String, backgroundColor: UIColor = .red) {
        guard let frame = view.window?.windowScene?.statusBarManager?.statusBarFrame else { return }
        let barView = InfoBarView.create(frame: frame, backgroundColor: .red)

        let alertWindow = PassTroughWindow()
        alertWindow.backgroundColor = UIColor.clear
        alertWindow.windowLevel = UIWindow.Level.alert
        alertWindow.isHidden = false
        alertWindow.makeKeyAndVisible()
        alertWindow.passTroughTag = 0
        alertWindow.addSubview(barView)

        NSLayoutConstraint.activate([
            barView.leadingAnchor.constraint(equalTo: alertWindow.leadingAnchor),
            barView.trailingAnchor.constraint(equalTo: alertWindow.trailingAnchor),
            barView.topAnchor.constraint(equalTo: alertWindow.topAnchor)
        ])

        barView.doAfter = {
            alertWindow.isHidden = true
        }

        barView.show(message: message)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            barView.hide()
        }
    }

    func handleError(error: Error) {
        let message = error.getMessage()
        showMessage(message, backgroundColor: .red)
    }
}

// MARK: - Activity indicator

extension UIViewController {
    var activityIndicatorTag: Int { 999_999 }
    var activityBackgroundViewTag: Int { 999_995 }

    func startActivity(aboveNavigationController: Bool = false, endEditing: Bool = true) {
        var view: UIView = self.view

        if endEditing {
            view.endEditing(true)
        }

        if aboveNavigationController, let navigationView = self.navigationController?.view {
            view = navigationView
        }

        if self.navigationController?.view.viewWithTag(activityBackgroundViewTag) != nil {
            stopActivity()
        }

        if self.view.viewWithTag(activityBackgroundViewTag) != nil {
            stopActivity()
        }

        DispatchQueue.main.async {
            let loadingView = UIActivityIndicatorView()
            loadingView.tag = self.activityBackgroundViewTag
            view.addSubview(loadingView)

            NSLayoutConstraint.activate([
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            loadingView.layoutIfNeeded()
            loadingView.startAnimating()
        }
    }

    func stopActivity(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async(execute: {
            self.view.subviews.filter { $0.tag == self.activityBackgroundViewTag }.forEach { activityBackgroundView in
                guard let activityBackgroundView = activityBackgroundView as? UIActivityIndicatorView else { return }
                activityBackgroundView.stopAnimating()
            }
        })

        DispatchQueue.main.async(execute: {
            self.navigationController?.view.subviews.filter { $0.tag == self.activityBackgroundViewTag }.forEach { activityBackgroundView in
                guard let activityBackgroundView = activityBackgroundView as? UIActivityIndicatorView else { return }
                activityBackgroundView.stopAnimating()
            }
        })

        DispatchQueue.main.async(execute: {
            self.view.subviews.filter { $0.tag == self.activityIndicatorTag }.forEach { loadingImageView in
                UIView.animate(withDuration: 0.2, animations: {
                    loadingImageView.alpha = 0.0
                }, completion: { finished in
                    if finished {
                        loadingImageView.removeFromSuperview()
                        if let completion = completion {
                            completion()
                        }
                    }
                })
            }

            self.navigationController?.view.subviews.filter { $0.tag == self.activityIndicatorTag }.forEach { loadingImageView in
                UIView.animate(withDuration: 0.2, animations: {
                    loadingImageView.alpha = 0.0
                }, completion: { finished in
                    if finished {
                        loadingImageView.removeFromSuperview()
                        if let completion = completion {
                            completion()
                        }
                    }
                })
            }
        })
    }
}
