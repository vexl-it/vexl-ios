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

    // MARK: - View State

    enum ViewState {
        case empty
        case loading
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

    @Published var currentState: ViewState = .loading
    @Published var items: [ImportContactItem] = []
    @Published var searchText = ""
    @Published var canImportContacts = false
    @Published var hasSelectedItem = false

    // MARK: - Variables

    var filteredItems: [ImportContactItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.name.contains(searchText) }
    }

    private let cancelBag: CancelBag = .init()

    // MARK: - Init

    init() {
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

        contactsManager
            .contacts
            .withUnretained(self)
            .sink { owner, content in
                switch content {
                case .empty:
                    owner.currentState = .empty
                    owner.items = []
                case .loading:
                    owner.currentState = .loading
                    owner.items = []
                case let .content(items):
                    owner.currentState = .content
                    owner.items = items
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
        contactsManager.fetchPhoneContacts()
    }
}
