//
//  RegisterPhoneViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import UIKit
import Cleevio

class RegisterPhoneViewController: BaseViewController<RegisterPhoneView> {

    private let pageView = RegistrationCounterView(numberOfItems: 3, currentIndex: 0)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
    }
}
