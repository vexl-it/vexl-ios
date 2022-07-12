//
//  WelcomeViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 23/02/22.
//

import UIKit
import SwiftUI
import Cleevio

class WelcomeViewController: BaseViewController<WelcomeView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.backButtonTitle = " "
        navigationController?.navigationBar.tintColor = .white
    }
}
