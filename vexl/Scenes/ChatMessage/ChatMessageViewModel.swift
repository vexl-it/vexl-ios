//
//  ChatMessageViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 29/05/22.
//

import Foundation
import Cleevio

final class ChatMessageViewModel: ViewModelType, ObservableObject {

    // MARK: - Action Binding

    enum UserAction: Equatable {
        case dismissTap
        case continueTap
        case chatActionTap(action: ChatMessageAction)
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    @Published var currentMessage: String = ""
    @Published var keyboardHeight: CGFloat = 0

    @Published var primaryActivity: Activity = .init()
    @Published var isLoading = false
    @Published var error: Error?

    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case dismissTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Variables

    var username: String {
        "Keichi"
    }

    var messages: [ChatMessageGroup] {
        ChatMessageGroup.stub
    }

    private let cancelBag: CancelBag = .init()

    init() {
        setupActionBindings()
    }

    private func setupActionBindings() {
        action
            .filter { $0 == .dismissTap }
            .map { _ -> Route in .dismissTapped }
            .subscribe(route)
            .store(in: cancelBag)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification, object: nil)
            .map(\.userInfo)
            .compactMap { userInfo -> CGFloat? in
                guard let frame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
                return frame.height
            }
            .assign(to: &$keyboardHeight)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification, object: nil)
            .map { _ in 0 }
            .assign(to: &$keyboardHeight)
    }
}
