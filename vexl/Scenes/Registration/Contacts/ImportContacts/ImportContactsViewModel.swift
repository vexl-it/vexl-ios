//
//  RegisterContacts+ImportViewModel.swift
//  vexl
//
//  Created by Diego Espinoza on 9/03/22.
//

import Foundation
import Combine
import SwiftUI
import Cleevio

class ImportContactsViewModel: ObservableObject {

    // MARK: - Dependencies

    @Inject var contactsManager: ContactsManager
    @Inject var contactsService: ContactsServiceType

    // MARK: - View State

    enum ViewState {
        case none
        case empty
        case content
        case success
    }

    // MARK: - Action Bindings

    enum UserAction {
        case itemSelected(Bool, ImportContactItem)
        case unselectAll
        case completed
    }

    let action: ActionSubject<UserAction> = .init()
    let completed: ActionSubject<Void> = .init()

    // MARK: - View Bindings

    @Published var currentState: ViewState = .none
    @Published var items: [ImportContactItem] = []
    @Published var searchText = ""
    @Published var hasSelectedItem = false

    @Published var loading = false
    @Published var error: AlertError?

    var primaryActivity: Activity = .init()
    var activityIndicator: ActivityIndicator {
        primaryActivity.indicator
    }
    var errorIndicator: ErrorIndicator {
        primaryActivity.error
    }

    // MARK: - Variables

    var filteredItems: [ImportContactItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.contains(searchText) }
    }

    let cancelBag: CancelBag = .init()

    // MARK: - Init

    init() {
        setupActivity()
        setupActions()
    }

    private func setupActivity() {
        activityIndicator
            .loading
            .assign(to: &$loading)

        errorIndicator
            .errors
            .withUnretained(self)
            .sink { owner, error in
                owner.error = AlertError(error: error)
            }
            .store(in: cancelBag)
    }

    private func setupActions() {
        action
            .withUnretained(self)
            .sink { owner, action in
                switch action {
                case let .itemSelected(isSelected, item):
                    owner.select(isSelected, item: item)
                case .unselectAll:
                    owner.unselectAllItems()
                case .completed:
                    owner.completed.send(())
                }
            }
            .store(in: cancelBag)
    }

    private func select(_ isSelected: Bool, item: ImportContactItem) {
        guard let selectedIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[selectedIndex].isSelected = isSelected
        hasSelectedItem = items.contains(where: { $0.isSelected })
    }

    private func unselectAllItems() {
        for index in items.indices {
            items[index].isSelected = false
        }
        hasSelectedItem = false
    }

    func fetchContacts() {
        fatalError("Must implement fetch contacts")
    }
}

class PhoneImportContactsViewModel: ImportContactsViewModel {
    override func fetchContacts() {
        let contacts = contactsManager.fetchPhoneContacts()
        let phones = contacts.map { $0.phone }

        contactsService
            .getAvailableContacts(phones)
            .track(activity: primaryActivity)
            .materialize()
            .withUnretained(self)
            .sink { owner, _ in
                let availableContacts = owner.contactsManager.availablePhoneContacts
                owner.currentState = availableContacts.isEmpty ? .empty : .content
                owner.items = availableContacts
            }
            .store(in: cancelBag)
    }
}

class FacebookImportContactsViewModel: ImportContactsViewModel {
    override func fetchContacts() {
        let contacts = contactsManager.fetchPhoneContacts()
    }
}
