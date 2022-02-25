//
//  RegisterNameAvatarViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 24/02/22.
//

import UIKit
import Cleevio

class RegisterNameAvatarViewController: BaseViewController<RegisterNameAvatarView> {

    private let pageView = RegistrationCounterView(numberOfItems: 3, currentIndex: 1)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pageView)
    }
}
