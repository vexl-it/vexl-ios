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

    @Inject var facebookManager: FacebookManagerType
    @Inject var userService: UserServiceType
    @Inject var contactsService: ContactsServiceType

    // MARK: - State

    enum ViewState {
        case initial
        case requestAccess
        case accessConfirmed
        case completed
    }

    // MARK: - Activities

    var primaryActivity: Activity
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }

    // MARK: - View Bindings

    @Published var currentState: ViewState = .initial

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case next
        case skip
        case cancel
    }

    let action: ActionSubject<UserAction> = .init()
    let accessConfirmed: ActionSubject<Void> = .init()
    let requestAccess: ActionSubject<Void> = .init()
    let completed: ActionSubject<Void> = .init()
    let skipped: ActionSubject<Void> = .init()

    // MARK: - Variables

    var title: String { "" }
    var image: Data? { nil }
    var subtitle: String { "" }
    var importButton: String { "" }
    var displaySkipButton: Bool { false }

    let cancelBag: CancelBag = .init()

    // MARK: - Init

    init(activity: Activity) {
        self.primaryActivity = activity
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
        case .requestAccess:
            requestAccess.send(())
        case .accessConfirmed:
            accessConfirmed.send(())
        case .initial:
            break
        }
    }
}
