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
    var phoneViewModel: RequestAccessContactsViewModel
    var facebookViewModel: RequestAccessContactsViewModel
    var importPhoneContactsViewModel: ImportPhoneContactsViewModel
    var importFacebookContactsViewModel: ImportFacebookContactsViewModel

    // MARK: - Variables

    private let cancelBag: CancelBag = .init()

    init(username: String) {
        phoneViewModel = RequestAccessPhoneContactsViewModel(username: username)
        importPhoneContactsViewModel = ImportPhoneContactsViewModel()
        facebookViewModel = RequestAccessFacebookContactsViewModel(username: username)
        importFacebookContactsViewModel = ImportFacebookContactsViewModel()
        setupRequestPhoneContactsBindings()
        setupImportPhoneContactsBindings()
        setupRequestFacebookContactsBindings()
        setupImportFacebookContactsBindings()
    }

    private func setupRequestPhoneContactsBindings() {
        phoneViewModel.accessConfirmed
            .withUnretained(self)
            .sink { owner, _ in
                owner.phoneViewModel.currentState = .completed
            }
            .store(in: cancelBag)

        phoneViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .importPhoneContacts
                owner.phoneViewModel.currentState = .initial
            }
            .store(in: cancelBag)
    }

    private func setupImportPhoneContactsBindings() {
        importPhoneContactsViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .facebook
                owner.importPhoneContactsViewModel.currentState = .loading
            }
            .store(in: cancelBag)

        importPhoneContactsViewModel.$items
            .withUnretained(self)
            .sink { _, items in
                // TODO: set selected items to a service/manager
                let selectedItems = items.filter { $0.isSelected }
                print(selectedItems)
            }
            .store(in: cancelBag)
    }

    private func setupRequestFacebookContactsBindings() {
        facebookViewModel.skipped
            .withUnretained(self)
            .sink { _, _ in
                // TODO: create user with service and message coordinator to go to the next view
            }
            .store(in: cancelBag)

        facebookViewModel.accessConfirmed
            .withUnretained(self)
            .sink { owner, _ in
                // TODO: request access to facebook sdk confirmation, set as complete to continue to next screen that has loading state and set the contacts to the ImportPhoneViewModel
                owner.facebookViewModel.currentState = .completed
                // TODO: remove this once integration with BE is done
                after(2) {
                    owner.importFacebookContactsViewModel.currentState = .content
                    owner.importFacebookContactsViewModel.items = ContactInformation.stub()
                }
            }
            .store(in: cancelBag)

        facebookViewModel.completed
            .withUnretained(self)
            .sink { owner, _ in
                owner.currentState = .importFacebookContacts
                owner.facebookViewModel.currentState = .initial
            }
            .store(in: cancelBag)
    }

    private func setupImportFacebookContactsBindings() {
        importFacebookContactsViewModel.$items
            .withUnretained(self)
            .sink { _, items in
                // TODO: set selected items to a service/manager
                let selectedItems = items.filter { $0.isSelected }
                print(selectedItems)
            }
            .store(in: cancelBag)

        importFacebookContactsViewModel.completed
            .withUnretained(self)
            .sink { _, _ in
                // TODO: - Create user with all the information, then message router to go next
            }
            .store(in: cancelBag)
    }
}
