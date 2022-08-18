//
//  GroupViewController.swift
//  vexl
//
//  Created by Diego Espinoza on 8/08/22.
//

import SwiftUI
import UIKit
import Cleevio

final class GroupViewController<T: View>: BaseViewController<T> {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = " "
    }
}
