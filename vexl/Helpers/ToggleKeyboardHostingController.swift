//
//  ToggleKeyboardHostingController.swift
//  vexl
//
//  Created by Daniel Fernandez Yopla on 27.05.2022.
//

import SwiftUI
import Cleevio

open class ToggleKeyboardHostingController<Content: View>: BaseViewController<Content>, UIGestureRecognizerDelegate {

    public override func viewDidLoad() {
        super.viewDidLoad()
        addDissmisKeyboardRecognizer()
    }

    private func addDissmisKeyboardRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    // MARK: - Keyboard

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isControlTapped = touch.view is UIControl
        return !isControlTapped
    }
}
