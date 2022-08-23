//
//  RegisterViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import UIKit
import SwiftUI
import Cleevio

final class RegisterViewController<T: View>: BaseViewController<T> {

    private let currentPage: Int
    private let numberOfPages: Int

    private lazy var pageView: RegistrationCounterView = {
        RegistrationCounterView(numberOfItems: self.numberOfPages,
                                currentIndex: self.currentPage)
    }()

    private lazy var backButton: UIBarButtonItem = {
        UIBarButtonItem(image: R.image.backButtonWithBackground(),
                        style: .done,
                        target: self,
                        action: #selector(onBackAction))
    }()

    @Published var showBackButton: Bool
    var onBack: ActionSubject<Void> = .init()

    init(currentPage: Int, numberOfPages: Int, rootView: T, showBackButton: Bool = true) {
        self.currentPage = currentPage
        self.numberOfPages = numberOfPages
        self.showBackButton = showBackButton
        super.init(rootView: rootView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        $showBackButton
            .withUnretained(self)
            .sink { owner, show in
                owner.navigationItem.setLeftBarButton(show ? owner.backButton : nil,
                                                      animated: true)
            }
            .store(in: cancelBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
    }

    @objc
    private func onBackAction() {
        onBack.send(())
    }
}
