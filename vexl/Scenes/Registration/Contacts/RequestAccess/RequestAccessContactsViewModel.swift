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
        case accessConfirmed
        case completed
    }

    // MARK: - View Bindings

    @Published var currentState: ViewState = .initial
    @Published var alert: RequestAccessContactsAlertType?

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case next
        case skip
        case cancel
    }

    let action: ActionSubject<UserAction> = .init()
    let accessConfirmed: ActionSubject<Void> = .init()
    let completed: ActionSubject<Void> = .init()
    let skipped: ActionSubject<Void> = .init()

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
        $currentState
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
                    owner.advanceCurrentState()
                case .cancel:
                    owner.cancelCurrentState()
                case .skip:
                    owner.skipped.send(())
                }
            }
            .store(in: cancelBag)
    }

    func advanceCurrentState() {
        fatalError("Method needs to be implemented")
    }

    func cancelCurrentState() {
        fatalError("Method needs to be implemented")
    }

    func update(state: ViewState) {
        switch state {
        case .completed:
            completed.send(())
        case .accessConfirmed:
            accessConfirmed.send(())
        case .initial, .confirmRejection, .requestAccess:
            break
        }
    }
}
