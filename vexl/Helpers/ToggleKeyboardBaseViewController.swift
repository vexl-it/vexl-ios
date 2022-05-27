//
//  ToggleKeyboardBaseViewController.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 27.05.2022.
//

import SwiftUI
import Cleevio

class ToggleKeyboardBaseViewController<RootView: View>: BaseViewController<RootView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        addDissmisKeyboardRecognizer()
    }

    private func addDissmisKeyboardRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Keyboard

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

