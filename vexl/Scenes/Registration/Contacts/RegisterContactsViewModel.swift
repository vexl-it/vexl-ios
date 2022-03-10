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

    @Published var currentState: ViewState = .importPhoneContacts
    @Published var phoneViewModel: PhoneViewModel
    @Published var importPhoneContactsViewModel: ImportContactViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init() {
        phoneViewModel = PhoneViewModel(userName: "Diego")
        importPhoneContactsViewModel = ImportContactViewModel()
        setupPhoneViewBindings()
        after(1) {
            self.importPhoneContactsViewModel.current = .loading
            after(1) {
                self.importPhoneContactsViewModel.current = .content
                self.importPhoneContactsViewModel.items = ContactItem.stub()
                after(1) {
                    self.importPhoneContactsViewModel.items = [.init(id: 4, name: "Diego Espinoza 4", phone: "9482 23 23", avatar: nil)]
                }
            }
        }
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

        static func stub() -> [ContactItem] {
            [
                ContactItem(id: 1, name: "Diego Espinoza 1", phone: "999 944 222", avatar: nil),
                ContactItem(id: 2, name: "Diego Espinoza 2", phone: "929 944 222", avatar: nil),
                ContactItem(id: 3, name: "Diego Espinoza 3", phone: "969 944 222", avatar: nil)
            ]
        }
    }
}
