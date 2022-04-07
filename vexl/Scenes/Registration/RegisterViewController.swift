//
//  RegisterViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import UIKit
import SwiftUI
import Cleevio

final class RegisterViewController<T: View>: AlertBaseViewController<T> {

    private let currentPage: Int
    private let numberOfPages: Int

    private lazy var pageView: RegistrationCounterView = {
        RegistrationCounterView(numberOfItems: self.numberOfPages,
                                currentIndex: self.currentPage)
    }()

    init(currentPage: Int, numberOfPages: Int, rootView: T) {
        self.currentPage = currentPage
        self.numberOfPages = numberOfPages
        super.init(rootView: rootView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
        navigationItem.backButtonTitle = " "
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
    }
}
