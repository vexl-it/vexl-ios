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
    @Published var phoneViewModel: PhoneViewModel
    @Published var importPhoneContactsViewModel: ImportContactViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        phoneViewModel = PhoneViewModel(userName: "Diego")
        importPhoneContactsViewModel = ImportContactViewModel()
        setupPhoneViewBindings()
        self.importPhoneContactsViewModel.current = .content
        self.importPhoneContactsViewModel.items = ContactItem.stub()
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

extension RegisterContactsViewModel {

    struct ContactItem: Identifiable {
        var id: Int
        var name: String
        var phone: String
        var avatar: Data?
        var isSelected = false

        static func stub() -> [ContactItem] {
            [
                ContactItem(id: 1, name: "Diego Espinoza 1", phone: "999 944 222", avatar: nil),
                ContactItem(id: 2, name: "Diego Espinoza 2", phone: "929 944 222", avatar: nil),
                ContactItem(id: 3, name: "Diego Espinoza 3", phone: "969 944 222", avatar: nil),
                ContactItem(id: 4, name: "Diego Espinoza 4", phone: "969 944 222", avatar: nil),
                ContactItem(id: 5, name: "Diego Test 4", phone: "969 944 222", avatar: nil)
            ]
        }
    }
}
