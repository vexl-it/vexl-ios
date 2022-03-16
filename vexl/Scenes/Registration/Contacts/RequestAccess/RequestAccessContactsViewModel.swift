//
//  RegisterContacts+PhoneViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

class RequestAccessContactsViewModel: ObservableObject {

    // MARK: - State

    enum ViewState {
        case initial
        case requestAccess
        case confirmRejection
        case completed
    }

    // MARK: - View Bindings

    @Published var current: ViewState = .initial
    @Published var alert: RequestAccessContactsAlertType?

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case next
        case cancel
        case completed
        case skip
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - Variables

    var userName: String
    var title: String { "" }
    var subtitle: String { "" }
    var importButton: String { "" }
    var displaySkipButton: Bool { false }
    var portraitColor: Color { Appearance.Colors.green5 }
    var portraitTextColor: Color { Appearance.Colors.green1 }

    private let cancelBag: CancelBag = .init()

    // MARK: - Init

    init(userName: String) {
        self.userName = userName
        $current
            .withUnretained(self)
            .sink { owner, state in
                owner.update(state: state)
            }
            .store(in: cancelBag)

        action
            .withUnretained(self)
            .sink { owner, action in
                switch action {
                case .next:
                    owner.next()
                case .cancel:
                    owner.cancel()
                case .completed, .skip:
                    break
                }
            }
            .store(in: cancelBag)
    }

    func next() { }

    func cancel() { }

    func update(state: ViewState) { }
}
