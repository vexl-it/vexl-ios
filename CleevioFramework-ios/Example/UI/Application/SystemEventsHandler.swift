//
//  SystemEventsHandler.swift
//  CleevioUIExample
//
//  Created by Thành Đỗ Long on 03.11.2020.
//

import UIKit
import Combine

protocol SystemEventsHandler {
    func sceneDidBecomeActive()
    func sceneWillResignActive()
}

struct SystemEventsHandlerImpl: SystemEventsHandler {
    let container: DIContainer
    private var cancelBag = CancelBag()

    init(container: DIContainer) {

        self.container = container
        installKeyboardHeightObserver()
    }

    private func installKeyboardHeightObserver() {
        let appState = container.appState
        NotificationCenter.default.keyboardHeightPublisher
            .sink { [appState] height in
                appState[\.system.keyboardHeight] = height
            }
            .store(in: cancelBag)
    }

    func sceneDidBecomeActive() {
        container.appState[\.system.isActive] = true
    }

    func sceneWillResignActive() {
        container.appState[\.system.isActive] = false
    }
}
// MARK: - Notifications

private extension NotificationCenter {
    var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        let willShow = publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let willHide = publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return Publishers.Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

private extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
            .cgRectValue.height ?? 0
    }
}
