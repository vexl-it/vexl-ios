//
//  RegisterPhoneContactsViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 7/03/22.
//

import Foundation
import Combine
import Cleevio
import SwiftUI

final class RegisterContactsViewModel: ViewModelType {

    // MARK: - View State

    enum ViewState {
        case phone
        case importPhoneContacts
        case facebook
        case importFacebookContacts
    }

    // MARK: - Actions Bindings

    enum UserAction: Equatable {
        case nextTap
    }

    let action: ActionSubject<UserAction> = .init()

    // MARK: - View Bindings

    var primaryActivity: Activity = .init()

    // MARK: - Coordinator Bindings

    enum Route: Equatable {
        case continueTapped
    }

    var route: CoordinatingSubject<Route> = .init()

    // MARK: - Subviews View Models and State

    @Published var currentState: ViewState = .phone
    @Published var phoneViewModel: RequestAccessContactsViewModel
    @Published var importPhoneContactsViewModel: ImportContactsViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        phoneViewModel = RequestAccessContactsViewModel(userName: "Diego")
        importPhoneContactsViewModel = ImportContactsViewModel()
        setupPhoneViewBindings()
        self.importPhoneContactsViewModel.current = .content
        self.importPhoneContactsViewModel.items = ImportContactsViewModel.ContactItem.stub()
    }

    private func setupPhoneViewBindings() {
        phoneViewModel.onCompleted
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .importPhoneContacts
                owner.phoneViewModel.current = .initial
            }
            .store(in: cancelBag)
    }
}
