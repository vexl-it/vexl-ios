//
//  AlertBaseViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 7/04/22.
//

import UIKit
import Cleevio
import SwiftUI
import Combine

class AlertBaseViewController<T: View>: BaseViewController<T> {

    @Published var error: Error?
    @Published var loading = false

    // TODO: - Remove this when BaseViewController cancelBag is made public
    
    var tempCancelBag: CancelBag = .init()
    
    private var loadingView: LoadingView = {
       LoadingView()
    }()

    override init(rootView: T) {
        super.init(rootView: rootView)
        setupErrorBinding()
        setupLoading()
    }

    private func setupErrorBinding() {
        $error
            .filter { $0 != nil }
            .withUnretained(self)
            .sink { owner, error in
                owner.presentError(title: error?.getMessage()) {
                    owner.error = nil
                }
            }
            .store(in: self.tempCancelBag)
    }
    
    private func setupLoading() {
        
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        $loading
            .withUnretained(self)
            .sink { owner, isLoading in
                owner.loadingView.isHidden = !isLoading
            }
            .store(in: self.tempCancelBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension AlertBaseViewController {

    class LoadingView: UIView {

        private lazy var dimmingView: UIView = {
            let dimmingView = UIView()
            dimmingView.translatesAutoresizingMaskIntoConstraints = false
            dimmingView.backgroundColor = .black
            dimmingView.alpha = 0.25
            return dimmingView
        }()

        private lazy var loadingView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = Appearance.GridGuide.point
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(activityIndicator)
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            return view
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)

            addSubview(dimmingView)
            NSLayoutConstraint.activate([
                dimmingView.topAnchor.constraint(equalTo: topAnchor),
                dimmingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                dimmingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            addSubview(loadingView)
            NSLayoutConstraint.activate([
                loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
                loadingView.centerYAnchor.constraint(equalTo: centerYAnchor),
                loadingView.heightAnchor.constraint(equalToConstant: Appearance.GridGuide.largeButtonHeight * 2),
                loadingView.widthAnchor.constraint(equalTo: loadingView.heightAnchor)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
